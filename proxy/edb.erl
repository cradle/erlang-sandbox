-module(edb).
-export([
  put/2, 
  get/1, 
  start/0, 
  stop/0,
  update_code/1
]).

put(Key, Value) ->
  put(Key, Value, edb_server).

put(Key, Value, Edb) ->
  Edb ! {put, Key, Value},
  ok.

get(Key) ->
  get(Key, edb_server).

get(Key, Edb) ->
  Edb ! {get, Key},
  ok. % return Value for Key

start() ->
  case (catch register(edb_server, internal())) of
    {'EXIT', _} ->
      already_started;
    Pid ->
      ok
  end.

stop() ->
  case (catch stop(edb_server)) of
    {'EXIT', _} ->
      not_running;
    shutdown ->
      ok
  end.

internal() ->
  spawn(fun() -> loop() end).

stop(Server) ->
  Server ! shutdown.

update_code(Edb) ->
  Edb ! {swap_code, fun(X) -> loop(X) end},
  ok.

loop() ->
  loop(dict:new()).

loop(Dict) ->
  receive
    {get, Key} ->
      case dict:find(Key, Dict) of
        error ->
          io:format("'~p' not found~n", [Key]);
        {ok, Value} ->
          io:format("Found: ~p~n", [Value])
      end,
      loop(Dict); % dict lookup for key
    {put, Key, Value} ->
      NewDict = dict:store(Key, Value, Dict),
      loop(NewDict);
    {swap_code, NewLoopFun} ->
      NewLoopFun(Dict);
    shutdown ->
      ok
  end.