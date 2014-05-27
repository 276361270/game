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
start_link([Port,ListenNum,FlashPort]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port,ListenNum,FlashPort]).

%% supervisor.

init([Port,ListenNum,FlashPort]) ->	
	 RanchSpec=?CHILD(ranch_sup,supervisor,[]),
	 GameSpec =?CHILD(game_tcp_sup,supervisor,[[Port,ListenNum]]),
	 GameFlashSpec=?CHILD(game_tcp_flash_sup,supervisor,[[FlashPort,ListenNum]]),
	 Childs=[RanchSpec,GameFlashSpec,GameSpec],
    {ok, {{one_for_one, 10, 10}, Childs}}.