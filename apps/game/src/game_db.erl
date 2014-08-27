%%
%% $Id: $
%%
%% Module:  boss_model -- description
%% Created: 01-MAY-2012 16:32
%% Author:  tmr
%%
-module(game_db).

-export([
  start_db/0,
  start_cache/0,
  stop_db/0,
  stop_cache/0,
  compile/2,
  edoc_module/2,
  is_model_instance/2,
  dummy_instance/1,
  to_json/1 %, from_json/1
  ]).

start_db() ->
  DBOptions = lists:foldl(fun(OptName, Acc) ->
          case game_env:get_env(OptName) of
            {ok, Val} -> [{OptName, Val}|Acc];
            _ -> Acc
          end
      end, [], [db_port, db_host, db_username, db_password, db_database, 
        db_replication_set, db_read_mode, db_write_mode, 
        db_write_host, db_write_host_port, db_read_capacity, 
        db_write_capacity, db_model_read_capacity, db_model_write_capacity]),
  
  DBAdapter = game_env:get_env(db_adapter, mock),
  DBShards = game_env:get_env(db_shards, []),
  CacheEnable = game_env:get_env(cache_enable, false),
  IsMasterNode = game_env:is_master_node(),
  CachePrefix = game_env:get_env(cache_prefix, db),
  DBCacheEnable = game_env:get_env(db_cache_enable, false) andalso CacheEnable,
  DBOptions1 = [{adapter, DBAdapter}, {cache_enable, DBCacheEnable}, {cache_prefix, CachePrefix},
      {shards, DBShards}, {is_master_node, IsMasterNode}|DBOptions],
  boss_news:start(), 
  boss_db:start(DBOptions1).

stop_db() ->
  boss_news:stop(),
  boss_db:stop().



start_cache() ->
  case game_env:get_env(cache_enable, false) of
    false ->
      error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p", [?MODULE,?LINE,"No Cache Start"]), 
      {ok,nocache};
    true  ->
      CacheAdapter = game_env:get_env(cache_adapter, memcached_bin),
      CacheOptions =
        case CacheAdapter of
        ets ->
          MaxSize   = game_env:get_env(ets_maxsize, 32 * 1024 * 1024),
          Threshold = game_env:get_env(ets_threshold, 0.85),
          Weight    = game_env:get_env(ets_weight, 30),
          [{adapter, ets}, 
            {ets_maxsize, MaxSize},
            {ets_threshold, Threshold},
            {ets_weight, Weight}];
        _ ->
          [{adapter, CacheAdapter},
            {cache_servers, game_env:get_env(cache_servers, [{"127.0.0.1", 11211, 1}])}]
      end,
      error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p", [?MODULE,?LINE,CacheOptions]), 
      boss_cache:start(CacheOptions)
  end.    

stop_cache()->
  boss_cache:stop() .   

compile(ModulePath, CompilerOptions) ->
  boss_record_compiler:compile(ModulePath, CompilerOptions).

edoc_module(ModulePath, Options) ->
  boss_record_compiler:edoc_module(ModulePath, Options).

is_model_instance(Object, AvailableModels) ->
  boss_record_lib:is_boss_record(Object, AvailableModels).

dummy_instance(Model) ->
  boss_record_lib:dummy_record(Model).

to_json(Object) ->
  Data = lists:map (fun
        ({Attr, Val}) when is_list (Val) ->
          {Attr, list_to_binary (Val)};
        ({Attr, {_,_,_} = Val}) ->
          {Attr, erlydtl_filters:date (calendar:now_to_datetime (Val), "F d, Y H:i:s")};
        ({Attr, {{_, _, _}, {_, _, _}} = Val}) ->
          {Attr, list_to_binary (erlydtl_filters:date (Val, "F d, Y H:i:s"))};
        (Other) ->
          Other
      end, Object:attributes()),
  {struct, Data}.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
