-module (game_login_sup).

-export([start_link/0]).

-behaviour(supervisor).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

%% @private
init({}) ->
	Login =
		{game_login_server,
			{game_login_server, start_link, []},
			permanent, 5000, worker,
			[game_login_server]},
	
	Children = [Login],
	RestartStrategy = {one_for_one, 5, 10},
	{ok, {RestartStrategy, Children}}.