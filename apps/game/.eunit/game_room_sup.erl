-module(game_room_sup).

-export([start_link/0]).

-behaviour(supervisor).

-export([init/1]).

-export([start_child/0, start_child/3]).

start_link() ->
    supervisor:start_link({local, ?MODULE},
			  ?MODULE, []).

start_child(RoomName, RoomPass, RoomOwer) ->
    supervisor:start_child(?MODULE,
			   [RoomName, RoomPass, RoomOwer]).

start_child() ->
    start_child("System", undefined, undefined).

init([]) ->
    Child = {game_room_server,
	     {game_room_server, start_link, []}, temporary,
	     brutal_kill, worker, [game_room_server]},
    Children = [Child],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.


