-module(node).
-export([start/0, send/2, stop/1, reload/1, connect/2, status/1]).

send(Message, Server) ->
  Server ! {chat, Message},
  ok.

stop(Server) ->
  Server ! shutdown,
  ok.

connect(Host, Server) ->
  Server ! {add_host, Host},
  ok.

status(Server) ->
  case process_info(Server) of
    undefined ->
      stopped;
    _ ->
      running
  end.

start() ->
  spawn(fun() -> loop() end).

reload(Server) ->
  Server ! {swap_code, fun() -> loop() end},
  ok.

loop() ->
  receive
    {swap_code, LoopFunc, Host} ->
      io:format("Remote reload (from ~p)~n", [Host]),
      LoopFunc();
    {swap_code, LoopFunc} ->
      [{server, N} ! {swap_code, LoopFunc, node()} || N <- nodes()],
      LoopFunc();
    {add_host, Host} ->
      Status = net_kernel:connect_node(Host),
      case Status of
        true -> ok;
        false -> io:format("Connection failed (~p)~n", [Host]);
        ignored -> io:format("Missing name (ie. erl -sname 'foo')")
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
      ok;
    Message ->
      io:format("Unknown message: ~p~n", Message),
      loop()
  end.