%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(game_app).
%%-include_lib("lager/include/lager.hrl").
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).
%% default listen port
-define(DEFAULT_PORT, 1156).
%% default listen number
-define(DEFAULT_LISTENNUM,10).
%% flash securty port 843
-define(FAHSNPORT, 8843).

%% API.

start(_Type, _Args) ->
	Port = case application:get_env(game, gameport) of
               {ok, P} -> P;
               undefined -> ?DEFAULT_PORT
         end,
  ListenNum = case application:get_env(game, listen) of
               {ok, NUM} ->NUM;
               undefined -> ?DEFAULT_LISTENNUM
           end,  
  FlashPort =  case application:get_env(game,flashport) of  
                {ok,PORT}->PORT;
                undefined -> ?FAHSNPORT
                end,              
    case game_sup:start_link([Port,ListenNum,FlashPort]) of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            {error, Other}
    end.
stop(_State) ->
	ok.
