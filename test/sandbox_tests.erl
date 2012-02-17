-module(sandbox_tests).

-include_lib("eunit/include/eunit.hrl").

ok_test() ->
    ?assertMatch({[1,2,3], _}, eval_sort()).

fail_test() ->
    ?assertException(error, {restricted, _}, eval_os()).

zipwith_and_exec_test() ->
    ?assertException(error, {restricted, _}, eval_zipwith_and_exec()).

apply_test() ->
    ?assertException(error, {restricted, _}, eval_apply()).

apply_in_fun_and_exec_test() ->
    ?assertException(error, {restricted, _}, eval_apply_in_fun_and_exec()).

local_test() ->
    ?assertException(error, {restricted, _}, eval_local()).

bindings_test() ->
    ?assertException(error, {restricted, _}, eval_bindings()).

%% Internal
eval_sort() ->
    sandbox:eval("lists:sort([3,2,1]).").

eval_os() ->
    sandbox:eval("os:cmd(foo).").

eval_zipwith_and_exec() ->
    E1 = "F = fun (M,F,A) -> lists:zipwith3({erlang, apply}, [M], [F], [ A ]) end.",
    {_, Bs} = sandbox:eval(E1, []),
    E2 = "F(init, stop, []).",
    sandbox:eval(E2, Bs).

eval_apply() ->
    sandbox:eval("erlang:apply(os, cmd, [foo]).").

eval_apply_in_fun_and_exec() ->
    E1 = "F = fun() -> erlang:apply(os, cmd, [foo]) end.",
    {_, Bs} = sandbox:eval(E1, []),
    E2 = "F().",
    sandbox:eval(E2, Bs).

eval_local() ->
    sandbox:eval("now().").

eval_bindings() ->
    sandbox:eval("b().").
