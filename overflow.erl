-module(overflow).
-compile(export_all).

loop(N) ->
  receive
    Func -> 
      io:format("Replaced Func [~p] ", [N]),
      StackSize = [Size || {stack_size, Size} <- process_info(self())],
      HeapSize = [Size || {heap_size, Size} <- process_info(self())],
      io:format("Stack~w Heap~w~n", [StackSize, HeapSize]),
      Func(N+1)
  end.

pop(N) ->
  Pid = spawn(fun() -> overflow:loop(0) end),
  pop(N, Pid).
pop(0, Pid) ->
  Pid;
pop(N, Pid) ->
  Pid ! fun(X) -> loop(X) end,
  pop(N-1, Pid).