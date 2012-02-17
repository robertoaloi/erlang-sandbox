-module(mock).

-export([b/0]).

b() ->
    erlang:display("urray").
