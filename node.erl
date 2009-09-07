-module(node).
-export([start/0, send/1, stop/0]).

send(Message) ->
  server ! {chat, Message},
  ok.

stop() ->
  server ! shutdown,
  ok.

start() ->
  Server = spawn(fun() -> loop() end),
  register(server, Server).

loop() ->
  receive
    {chat, Message} ->
      % io:format("You: ~p~n", [Message]),
      [{server, N} ! {print, Message, node()} || N <- nodes()],
      loop();
    {print, Message, Node} ->
      io:format("~p: ~p~n", [Node, Message]),
      loop();
    reload ->
      loop();
    shutdown ->
      ok;
    Message ->
      io:format("Unknown message: ~p~n", Message),
      loop()
  end.