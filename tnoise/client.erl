-module(client).
-export([start/1, reload/1]).

start(ServerName) ->
  Pid = spawn(fun() -> again() end),
  {server, ServerName} ! {register, Pid},
  Pid.

chat(Message, Client) ->

reload(Client) ->
  Client ! {update_code, fun() -> again() end},
  ok.

again() ->
  receive
    shutdown ->
      ok;
    {update_code, Again} ->
      io:format("Updating Code.~n"),
      Again();
    Msg ->
      io:format("Unknown Message: ~p~n", [Msg]),
      again()
  end.
