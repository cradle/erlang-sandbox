-module(server).
-export([start/0, register/1, reload/1]).

start() ->
  spawn(fun() -> again() end).

register(Server) ->
  register(server, Server).
  
reload(Server) ->
  Server ! {update_code, fun() -> again() end},
  ok.

again() ->
  again([]).
again(Users) ->
  receive
    {connect, User} ->
      again([User|Users]);
    {print, Message} ->
      io:format("Printing: ~p~n", [Message]),
      again();
    shutdown ->
      ok;
    {update_code, Again} ->
      io:format("Updating Code.~n"),
      Again();
    Msg ->
      io:format("Unknown Message: ~p~n", [Msg]),
      again()
  end.