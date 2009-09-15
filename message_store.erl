-module(message_store).

-compile([export_all]).

-define(SERVER, message_store).

start(ServerNameNameNameServerNameName) ->
  global:trans({?SERVER, ?SERVER},
    fun() ->
      case global:whereis_name(?SERVER) of
        undefined ->
          Pid = spawn(message_router, route_messages, [dict:new()]),
          global:register_name(?SERVER, Pid);
        _ ->
          ok
      end
    end).

stop() ->
  ok

