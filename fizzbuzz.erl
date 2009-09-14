-module(fizzbuzz).
-export([run/0, go/1]).

run() ->
  run(100).
run(0) ->
  io:format("~p~n", [go(0)]);
run(X) ->
  io:format("~p ", [go(X)]),
  run(X-1).

go([Head|[]]) ->
  io:format("~p~n", [go(Head)]);
go([Head|Tail]) ->
  io:format("~p, ", [go(Head)]),
  go(Tail);
go(X) when X rem 5 == 0, X rem 3 == 0 ->
  'fizzbuzz';
go(X) when X rem 5 == 0 ->
  'buzz';
go(X) when X rem 3 == 0 ->
  'fizz';
go(X) ->
  X.