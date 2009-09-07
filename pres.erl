-module(pres).
-compile(export_all).

length() ->
  0.

length([]) ->
  0;
length([_|Rest]) ->
  1 + pres:length(Rest).

pretty_size(X) when X > 7.5 ->
  "woah nelly!";
pretty_size(_) ->
  "average joe.".
  
factorial(0) ->
  1;
factorial(X) ->
  X * factorial(X-1).
  
convert_to_inches({centimeters, X}) ->
    {inches, X / 2.54};
convert_to_inches({inches, X}) ->
    {inches, X}.