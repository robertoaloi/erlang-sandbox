-module(sandbox_tests).

-include_lib("eunit/include/eunit.hrl").

ok_test() ->
    ?assertMatch({[1,2,3], _}, eval_sort()).

fail_test() ->
    ?assertException(error, {restricted, _}, eval_os()).

zipwith_and_exec_test() ->
    ?assertException(error, {restricted}, eval_zipwith_and_exec()).

apply_test() ->
    ?assertException(error, {restricted, _}, eval_apply()).

apply_in_fun_and_exec_test() ->
    ?assertException(error, {restricted, _}, eval_apply_in_fun_and_exec()).

local_test() ->
    ?assertException(error, {restricted, _}, eval_local()).

bindings_test() ->
    ?assertException(error, {restricted, _}, eval_bindings()).

seq_test() ->
    ?assertMatch({[1,2,3,4,5], _}, eval_good_seq_2()),
    ?assertMatch({[5,4,3,2,1], _}, eval_good_seq_3()),
    ?assertException(error, {restricted, _}, eval_bad_seq_2()),
    ?assertException(error, {restricted, _}, eval_bad_seq_3()).

boolean_test() ->
    ?assertMatch({false, _}, eval_boolean()).

%% Internal
eval_sort() ->
    sandbox:eval("lists:sort([3,2,1]).").

eval_os() ->
    sandbox:eval("os:cmd(foo).").

eval_zipwith_and_exec() ->
    E1 = "F = fun (M,F,A) -> lists:zipwith3({erlang, apply}, [M], [F], [ A ]) end.",
    sandbox:eval(E1, []).

eval_apply() ->
    sandbox:eval("erlang:apply(os, cmd, [foo]).").

eval_apply_in_fun_and_exec() ->
    E1 = "F = fun() -> erlang:apply(os, cmd, [foo]) end.",
    {_, Bs} = sandbox:eval(E1, []),
    E2 = "F().",
    sandbox:eval(E2, Bs).

eval_local() ->
    sandbox:eval("term_to_binary(pigeon).").

eval_bindings() ->
    sandbox:eval("b().").

eval_good_seq_2() ->
    E1 = "lists:seq(1, 5).",
    sandbox:eval(E1).

eval_good_seq_3() ->
    E1 = "lists:seq(5, 1, -1).",
    sandbox:eval(E1).

eval_bad_seq_2() ->
    E1 = "lists:seq(1, 250).",
    sandbox:eval(E1).

eval_bad_seq_3() ->
    E1 = "lists:seq(250, 1, -1).",
    sandbox:eval(E1).

eval_boolean() ->
    E1 = "true andalso false.",
    sandbox:eval(E1).
