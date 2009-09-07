-module(msgr).
-export([start/0, main/0]).

start() ->
  receive
    shutdown ->
      io:format("Shutting down.~n");
    Args ->
      io:format("Server printing: ~p~n", [Args]),
      main()
  end.

start() ->
  register(server, spawn(msg, main, [])).