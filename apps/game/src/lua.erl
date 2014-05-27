-module(lua).
-export([print/0]).
print()->
    luerl:do("print(\"Hello, Robert(o)!\")"),

    % execute a file
    {Rs,_ST}=luerl:dofile(code:priv_dir(game)++"/hello.lua"),
    io:format("~p",[Rs]),
    
    % separately parse, then execute
    {ok, Chunk} = luerl:load("print(\"Hello, Chunk!\")"),
    State = luerl:init(),
    {_Ret, _NewState} = luerl:do(Chunk, State),

    done.   