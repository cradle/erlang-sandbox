-module(overflow).
-compile(export_all).

loop(N) ->
  receive
    Func -> 
      io:format("Replaced Func ~p times~n", [N]),
      Func(N+1)
  end.