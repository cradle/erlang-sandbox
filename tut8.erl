-module(tut8).
-export([reverse/1]).

reverse(List) ->
  reverse(List, []).

reverse([Head | Rest], ReversedList) ->
  reverse(Rest, [Head | ReversedList]);
reverse([], ReversedList) ->
  ReversedList.