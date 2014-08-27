-module(game_env).
-define (APP, game).
-export([game_env/0, get_env/1,setup_game_env/0, get_env/2, get_env/3]).
-export([master_node/0, is_master_node/0, is_developing_app/1]).


game_env() ->
    case get(game_environment) of
        undefined -> setup_game_env();
        Val -> Val
    end.

setup_game_env() -> 
    case module_is_loaded(reloader) of
        true  -> put(boss_environment, development), development;
        false -> put(boss_environment, production), production
    end.            

get_env(App, Key, Default) when is_atom(App), is_atom(Key) ->
    case application:get_env(App, Key) of
        {ok, Val} -> Val;
        _ -> Default
    end.

get_env(Key, Default) when is_atom(Key) ->
    get_env(?APP, Key, Default).

get_env(Key) when is_atom(Key) ->
    application:get_env(?APP, Key).    

master_node() ->
    case get_env(master_node, erlang:node()) of
        MasterNode when is_list(MasterNode) ->
            list_to_atom(MasterNode);
        MasterNode -> MasterNode
    end.

is_master_node() ->
    master_node() =:= erlang:node().

is_developing_app(AppName) ->
    BossEnv     = game_env(),
    DevelopingApp   = get_env(developing_app, undefined),
    AppName     =:= DevelopingApp andalso BossEnv =:= development.

module_is_loaded(Module) ->
    case code:is_loaded(Module) of
        {file, _} ->
            true;
        _ ->
            false
    end.