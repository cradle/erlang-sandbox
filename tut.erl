-module(tut).
-export([fac/1, mult/2]).

fac(1) ->
  1;
fac(N) ->
  N * fac(N-1).

factorial(N) ->
  factorial(N, 1).

factorial(0, Accumulator) ->
  Accumulator,
factorial(N, Accumulator) ->
  factorial(N-1, N*Accumulator).

mult(X, Y) ->
  X * Y.