-module(node).
-export([start/0, send/1, stop/0, reload/0, connect/1]).

send(Message) ->
  {server, node()} ! {chat, Message},
  ok.

stop() ->
  case whereis(server) of
    undefined -> 
      not_running;
    Pid -> 
      Pid ! shutdown,
      ok
  end.

connect(Host) ->
  case whereis(server) of
    undefined -> 
      not_running;
    Pid -> 
      Pid ! {add_host, Host},
      ok
  end.

start() ->
  case whereis(server) of
    undefined ->
      Server = spawn(fun() -> loop() end),
      register(server, Server);
    Pid ->
      {already_running, Pid}
  end.

reload() ->
  case whereis(server) of
    undefined -> 
      not_running;
    Pid -> 
      Pid ! {swap_code, fun() -> loop() end},
      ok
  end.

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