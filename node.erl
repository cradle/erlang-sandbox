-module(node).
-export([start/0, send/1, stop/0, reload/0, connect/1]).

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

reload() ->
  io:format("Swapping code~n"),
  % TODO: Fix this, it's not exiting the old 'loop()' (stack overflow?)
  {server, node()} ! {swap_code, fun() -> loop() end},
  ok.

loop() ->
  io:format("Waiting~n"),
  receive
    {swap_code, LoopFunc, Host} ->
      io:format("Loading new code (requested by ~p)~n", [Host]),
      LoopFunc();
    {swap_code, LoopFunc} ->
      io:format("Reloading other nodes~n"),
      [{server, N} ! {swap_code, LoopFunc, node()} || N <- nodes()],
      io:format("Loading new code~n"),
      LoopFunc();
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