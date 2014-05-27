-module(game_tcp_flash_sup).

-export([start_link/1]).

-behaviour(supervisor).

-export([init/1]).

-define(SERVER, ?MODULE).

-define(CHILD(I, Type,Parms), {I, {I, start_link,Parms}, permanent, 5000, Type, [I]}).

start_link([Port,ListenNum]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port,ListenNum]).

%% supervisor.

init([Port,ListenNum]) ->	
	 PolicySpec = ?CHILD(game_policy_sup,supervisor,[]),
     ListenerSpec = ranch:child_spec(game_tcp_flash_server,ListenNum,ranch_tcp, [{port, Port}], game_tcp_flash_server, []),
     Childs=[PolicySpec,ListenerSpec],
    {ok, {{one_for_one, 10, 10}, Childs}}.