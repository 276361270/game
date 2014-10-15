%%%-------------------------------------------------------------------
%%% @author thinkpad <>
%%% @copyright (C) 2014, thinkpad
%%% @doc
%%%
%%% @end
%%% Created : 27 Jun 2014 by thinkpad <>
%%%-------------------------------------------------------------------
-module(game).

%% API
-export([start/0,stop/0]).

%%%===================================================================
%%% API
%%%===================================================================
start()->
    ensure_started(sasl),
    ensure_started(crypto),
    ensure_started(mnesia),  
    ensure_started(syntax_tools),
    ensure_started(compiler),
    ensure_started(goldrush), 
    ensure_started(lager),   
    ensure_started(luerl),
    ensure_started(ibrowse), 
    ensure_started(cowlib),
    ensure_started(cowboy),
    ensure_started(resource_discovery),
    ensure_started(msgpack),
    ensure_started(sync),
    ensure_started(game).

stop()->
    application:stop(game).

%% start applicaiton 
ensure_started(App) ->
    case application:start(App) of
        ok ->
            error_logger:info_msg("Module is :~p,Line is :~p Message is  : ~p", [?MODULE,?LINE,App]),
            ok;
        {error, {already_started, App}} ->
            ok
    end.

