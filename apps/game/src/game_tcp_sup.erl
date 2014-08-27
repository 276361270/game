%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(game_tcp_sup).
-behaviour(supervisor).

%% API.
-export([start_link/1]).

%% supervisor.
-export([init/1]).

%% API.
start_link([Port,ListenNum]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port,ListenNum]).

%% supervisor.

init([Port,ListenNum]) ->	
     ListenerSpec = ranch:child_spec(game_tcp_server,ListenNum,ranch_tcp, [{port, Port}], game_tcp_server, []),
     Childs=[ListenerSpec],
    {ok, {{one_for_one, 10, 10}, Childs}}.