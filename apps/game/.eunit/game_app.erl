%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(game_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).
-export([profile_output/0]).
%% default listen port
-define(DEFAULT_PORT, 1156).
%% default listen number
-define(DEFAULT_LISTENNUM,10).
%% flash securty port 843
-define(FAHSNPORT, 8843).
%%websocket port
-define(WEBPORT,8080).
%% default websocket listen number
-define(WEB_LISTENNUM,10).
%% wait for res
-define(WAIT_FOR_RESOURCES, 500).
%% API.

start(_Type, _Args) ->
    _=consider_profiling(),
    Port= application:get_env(game, gameport,?DEFAULT_PORT),
    ListenNum =  application:get_env(game, listen,?DEFAULT_LISTENNUM),    
    FlashPort =   application:get_env(game,flashport,?FAHSNPORT),      
    WebPort =   application:get_env(game,webport,?WEBPORT),    
    WebListenNum =  application:get_env(game,weblisten,?WEB_LISTENNUM),
    addresource(), 
    ok = game_store:init(),
    case game_sup:start_link([Port,ListenNum,FlashPort,WebPort,WebListenNum]) of
        {ok, Pid} ->
            error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p", [?MODULE,?LINE,"Start it ok"]), 
            {ok, Pid};
        Other ->
            {error, Other}
    end.
stop(_State) ->
    ok.


addresource()->
    resource_discovery:add_local_resource_tuple({game,node()}),
    resource_discovery:add_target_resource_type(game),
    resource_discovery:trade_resources(),
    timer:sleep(?WAIT_FOR_RESOURCES).

-spec profile_output() -> ok.
profile_output() ->
    eprof:stop_profiling(),
    eprof:log("procs.profile"),
    eprof:analyze(procs),
    eprof:log("total.profile"),
    eprof:analyze(total).

%% Internal.

-spec consider_profiling() -> profiling | not_profiling.
consider_profiling() ->
    case application:get_env(profile) of
        {ok, true} ->
            {ok, _Pid} = eprof:start(),
            eprof:start_profiling([self()]);
        _ ->
            not_profiling
    end.

