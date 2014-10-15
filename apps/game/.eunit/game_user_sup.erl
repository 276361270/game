-module(game_user_sup).

-export([start_link/0]).

-export([start_child/2]).

-behaviour(supervisor).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE},
			  ?MODULE, []).

start_child(UserID, UserName) ->
    supervisor:start_child(?MODULE,
			   [UserID, UserName]).

init([]) ->
    Child = {game_user_server,
	     {game_user_server, start_link, []}, temporary,
	     brutal_kill, worker, [game_user_server]},
    Children = [Child],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.


