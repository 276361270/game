%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(game_sup).
-behaviour(supervisor).

%% API.
-export([start_link/1]).

%% supervisor.
-export([init/1]).

-define(CHILD(I, Type,Parms), {I, {I, start_link,Parms}, permanent, 5000, Type, [I]}).

%% API.
start_link([Port,ListenNum,FlashPort,WebPort,WebListenNum]) ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Port,ListenNum,FlashPort,WebPort,WebListenNum]).

%% supervisor.

init([Port,ListenNum,FlashPort,WebPort,WebListenNum]) ->
  	{ok,_} = game_db:start_db(),
    {ok,_} = game_db:start_cache() , 
	RanchSpec=?CHILD(ranch_sup,supervisor,[]),
	WebSocket=?CHILD(game_wsocket_sup,supervisor,[[WebPort,WebListenNum]]),
	GameSpec =?CHILD(game_tcp_sup,supervisor,[[Port,ListenNum]]),
	GameFlashSpec=?CHILD(game_tcp_flash_sup,supervisor,[[FlashPort,ListenNum]]),
	User =?CHILD(game_user_sup,supervisor,[]),
	Room =?CHILD(game_room_sup,supervisor,[]),
	Login =?CHILD(game_login_sup,supervisor,[]),	
	Childs=[RanchSpec,GameFlashSpec,GameSpec,WebSocket,Login,User,Room],
	{ok, {{one_for_one, 10, 10}, Childs}}.
