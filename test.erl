-module(test).
-compile([export_all]).

run() ->
  receive
    stop ->
      io:format("Shutting down~n"),
      ok;
    _ ->
      io:format("Looping~n"),
      run()
  end.

start() ->
  Runner = spawn(test, run, []).
  Runner ! keep_running, % "Looping"
  Runner ! [can, pass, anything], % "Looping"
  Runner ! stop, % "Shutting down"
  Runner ! are_you_ok. % does nothing