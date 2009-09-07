-module(mesh).
-export([start/0, start/1, restart/0, stop/0, connect/1]).

loop() ->
  loop([]).

loop(Servers) ->
  receive
    shutdown ->
      io:format("Shutting down.~n"),
      ok;
    {connect, Host} ->
      io:format("Connecting to: ~p.~n", [Host]),
      {server, Host} ! {add_server, self()}},
      loop(Servers);
    {add_server, Server} ->
      io:format("Received connection from: ~p.~n", [Server]),
      Server ! {add_server, {pid, self()}},
      io:format("Sending callback.~n"),
      loop([Server | Servers]);
    {add_server, {pid, Server}} ->
      io:format("Received callback, adding other servers: ~p.~n", [OtherServers]),
      loop(Servers ++ OtherServers);
    list_connections ->
      io:format("Connections: ~p~n", [Servers]),
      loop(Servers);
    Msg ->
      io:format("Printing: ~p~n", [Msg]),
      loop(Servers)
  end.

connect(Host) ->
  {server, node()} ! {connect, {name, Host}},
  ok.

restart() ->
  stop(),
  start(),
  ok.
  
start(Name) ->
  case net_kernel:start([Name, shortnames]) of
    {ok, _} ->
      start();
    {error, {{already_started, _}, _}} ->
      io:format("Already started with name: ~p, (use start/0)~n", [node()]);
    {error, Message} ->
      io:format("Unable to start server ~p, reason: ~p~n", [Name, Message])
  end.

start() ->
  case is_alive() of
    true ->
      Server = spawn(fun() -> loop() end),
      register(server, Server),
      ok;
    false ->
      {error, "Needs a node name (use start/1)"}
  end.

stop() ->
  {server, node()} ! shutdown,
  net_kernel:stop(),
  ok.