-module(node).
-export([start/0, send/1, stop/0, restart/0, connect/1]).

send(Message) ->
  {server, node()} ! {chat, Message},
  ok.

stop() ->
  {server, node()} ! shutdown,
  ok.

connect(Host) ->
  {server, node()} ! {add_host, Host},
  ok.

start() ->
  io:format("Starting~n"),
  Server = spawn(fun() -> loop() end),
  register(server, Server),
  io:format("Started~n").

restart() ->
  stop(),
  start().

loop() ->
  io:format("Waiting...~n"),
  receive
    {add_host, Host} ->
      io:format("Connecting to: ~p~n", [Host]),
      Status = net_kernel:connect_node(Host),
      case Status of
        true -> io:format("Connected to ~p~n", [Host]);
        false -> io:format("Unable to connect to ~p~n", [Host]);
        ignored -> io:format("Not started with name (ie. erl -sname 'foo')")
      end,
      loop();
    {chat, Message} ->
      io:format("You: ~p~n", [Message]),
      [{server, N} ! {print, Message, node()} || N <- nodes()],
      loop();
    {print, Message, Node} ->
      io:format("~p: ~p~n", [Node, Message]),
      loop();
    shutdown ->
      io:format("Stopping~n"),
      ok;
    Message ->
      io:format("Unknown message: ~p~n", Message),
      loop()
  end.