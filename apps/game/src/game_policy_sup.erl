-module(game_policy_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

-define(CHILD(I, Type,Parms), {I, {I, start_link,Parms}, permanent, 5000, Type, [I]}).

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% @private
init([]) ->
	Child =?CHILD(game_policy_server,worker,[liberal]),
	Children = [Child],
	RestartStrategy = {one_for_one, 5, 10},
	{ok, {RestartStrategy, Children}}.