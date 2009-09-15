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
  spawn(fun() -> client() end).

reload(Server) ->
  Server ! {swap_code, fun() -> loop() end},
  ok.

manager(Servers) ->
  receive
    {register, Pid} ->
      manager([Pid|Servers]);
    {broadcast, Message} ->
      [Pid ! Message || Pid <- Servers],
      mananger(Servers);
    shutdown ->
      ok
  end.

client() ->
  receive
    {swap_code, clientFunc, Host} ->
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
      client();
    {chat, Message} ->
      io:format("You: ~p~n", [Message]),
      % this no longer works, because we've stopped using named processes
      [{server, N} ! {print, Message, node()} || N <- nodes()],
      client();
    {print, Message, Node} ->
      io:format("~p: ~p~n", [Node, Message]),
      client();
    shutdown ->
      ok;
    Message ->
      io:format("Unknown message: ~p~n", Message),
      client()
  end.