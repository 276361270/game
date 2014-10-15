-module(game_pack).

-export([pack/1, unpack/1]).

-export([pack_compress/1, unpack_compress/1]).

-define(PACKAGE, [{format, map}]).

-export([get_value/2, set_value/3, find_value/2,
	 add_value/3]).

pack(Map) ->
    case msgpack:pack(Map, ?PACKAGE) of
      {error, Data} ->
	  error_logger:error_msg("Module is: ~p,Line is: ~p Message is: ~p",
				 [?MODULE, ?LINE, Data]);
      Binary -> {ok, Binary}
    end.

unpack(Binary) ->
    case msgpack:unpack(Binary,?PACKAGE) of
      {ok, Data} -> {ok, Data};
      {error, Err} ->
	  error_logger:error_msg("Module is: ~p,Line is: ~p Message is: ~p",
				 [?MODULE, ?LINE, Err])
    end.

pack_compress(Map) ->
    case pack(Map) of
      {error, Reason} ->
	  error_logger:error_msg("Module is: ~p,Line is: ~p Message is: ~p",
				 [?MODULE, ?LINE, Reason]);
      {ok, Binary} -> {ok, zlib:compress(Binary)}
    end.

unpack_compress(Binary) ->
    case zlib:uncompress(Binary) of
      {'EXIT', Reason} ->
	  error_logger:error_msg("Module is: ~p,Line is: ~p Message is: ~p",
				 [?MODULE, ?LINE, Reason]);
      Bin -> unpack(Bin)
    end.

get_value(Key, Map) when is_list(Key) ->
    maps:get(list_to_binary(Key), Map).

set_value(Key, Value, Map) when is_list(Key) ->
    maps:update(list_to_binary(Key), Value, Map).

add_value(Key, Value, Map) when is_list(Key) ->
    maps:put(list_to_binary(Key), Value, Map).

find_value(Key, Map) when is_list(Key) ->
    maps:find(list_to_binary(Key), Map).


