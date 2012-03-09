-module(sandbox).

-export([eval/1, eval/2]).

-define(MAX_HEAP_SIZE, 10000).
-define(MAX_ARGS_SIZE, 200).

eval(E) ->
    eval(E, []).

eval(E, Bs) -> 
    {ok, Tokens, _} = erl_scan:string(E),
    {ok, Exprs} = erl_parse:parse_exprs(Tokens),
    SafeExprs = safe_exprs(Exprs),
    {value, Value, NBs} = erl_eval:exprs(SafeExprs, Bs, {eval, fun lh/3}, {value, fun nlh/2}),
    {Value, NBs}.

lh(f, [], _Bs) ->
    {value, ok, erl_eval:new_bindings()};
lh(f, [{var,_,Name}], Bs) ->
    {value, ok, erl_eval:del_binding(Name, Bs)};
lh(F, Args, Bs) ->
    Arity = length(Args),
    case erlang:function_exported(user_default, F, Arity) of
	true ->
            {eval, erlang:make_fun(user_default, F, Arity), Args, Bs};
	false ->
            {value, erlang:error({restricted, [{F, Args}]}), Bs}
    end.

nlh({M, F}, Args) ->
    apply(M, F, Args);
nlh(F, Args) ->
    erlang:error({restricted, [{F, length(Args)}]}). 

safe_application(Node) ->
    case erl_syntax:type(Node) of
        application ->
            case erl_syntax_lib:analyze_application(Node) of
                {Module, {Function, Arity}} ->
                    Args = erl_syntax:application_arguments(Node),
                    case restrictions:is_allowed(Module, Function, Args) of
                        {true, Mock} ->
                            erl_syntax:application(
                              erl_syntax:atom(Mock),
                              erl_syntax:atom(Function),
                              Args);
                        true ->
                            Node;
                        false ->
                            erlang:error({restricted, [Module, Function, Arity]})
                    end;
                {Function, Arity} ->
                    Args = erl_syntax:application_arguments(Node),
                    case restrictions:is_allowed(Function, Args) of
                        {true, Mock} ->
                            erl_syntax:application(
                              erl_syntax:atom(Mock),
                              erl_syntax:atom(Function),
                              Args);
                        true ->
                            Node;
                        false ->
                            erlang:error({restricted, [Function, Arity]})
                    end;
                Arity ->
                    erlang:error({restricted, [Arity]})
            end;
        _ ->
            Node
    end.

safe_exprs(Exprs) ->
    revert(safe_expr(Exprs)).

revert(Tree) ->
    [erl_syntax:revert(T) || T <- lists:flatten(Tree)].

safe_expr(Exprs) when is_list(Exprs) ->
    [safe_expr(Expr) || Expr <- Exprs];
safe_expr(Expr) ->
    postorder(fun safe_application/1, Expr).

postorder(F, Tree) ->
    F(case erl_syntax:subtrees(Tree) of
          [] ->
              Tree;
          List ->
              erl_syntax:update_tree(Tree,
                                     [[postorder(F, Subtree)
                                       || Subtree <- Group]
                                      || Group <- List])
      end).
