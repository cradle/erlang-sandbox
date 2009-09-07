-module(loop).

-compile(export_all).

say_something(What) ->
    What.

start() ->
    spawn(loop, say_something, something).