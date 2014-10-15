%%%-------------------------------------------------------------------
%%% @author thinkpad <>
%%% @copyright (C) 2014, thinkpad
%%% @doc
%%%
%%% @end
%%% Created : 27 Jun 2014 by thinkpad <>
%%%-------------------------------------------------------------------
-module(game_store).

-include_lib("stdlib/include/qlc.hrl" ).
%% API
-export([dirty_insert/2,dirty_lookall/0,dirty_lookall_record/0,dirty_delete/1,dirty_lookup/1]).

-export([init/0,insert/2,delete/1,lookup/1,lookall/0]).

-record(socket_to_pid, {pid,socket_type}).

-record(user_info,{name,islogin}).

-define(WAIT_FOR_TABLES, 10000).

%%%===================================================================
%%% API
%%%===================================================================
init()->
    CacheNode=resource_discovery:get_resources(game),
    dynamic_db_init(lists:delete(node(),CacheNode)).

%--------------------------------------------------------------------
%% @doc Insert a key and pid.
%% @spec insert(Key, Pid) -> void()
%% @end
%%--------------------------------------------------------------------
insert(Pid,SocketType) when is_pid(Pid) ->
    mnesia:dirty_write(#user_info{name=pid,islogin=false}),
    Fun = fun() -> mnesia:write(#socket_to_pid{pid = Pid, socket_type = SocketType}) end,
    {atomic, _} = mnesia:transaction(Fun).

%--------------------------------------------------------------------
%% @doc  dirty insert pid and socket
%% @spec  dirty_insert(Pid socket)
%% @end
%%--------------------------------------------------------------------

dirty_insert(Pid,SocketType) when is_pid(Pid) ->
    mnesia:dirty_write(#socket_to_pid{pid = Pid, socket_type = SocketType}).
%--------------------------------------------------------------------
%% @doc dirty_read data
%% @spec dirty_lookall()
%% @end
%%--------------------------------------------------------------------

dirty_lookall()->
    mnesia:dirty_select(socket_to_pid,[{#socket_to_pid{pid='$1',socket_type = '$2'},[],['$$']}]).

dirty_delete(Pid)->
    mnesia:dirty_delete(socket_to_pid,Pid).

%--------------------------------------------------------------------
%% @doc look all record info
%% @spec 
%% @end
%%--------------------------------------------------------------------

dirty_lookall_record()->    
    mnesia:dirty_select(socket_to_pid,[{#socket_to_pid{pid='$1',socket_type = '$2'},[],['$_']}]).

dirty_lookup(Pid)->
    
    mnesia:dirty_read(socket_to_pid,Pid). 
%%--------------------------------------------------------------------
%% @doc Find a pid given a key.
%% @spec lookup(Key) -> {ok, Pid} | {error, not_found}
%% @end
%%--------------------------------------------------------------------
lookup(Pid) ->
    do(qlc:q([{X#socket_to_pid.pid,X#socket_to_pid.socket_type} || X <- mnesia:table(socket_to_pid),X#socket_to_pid.pid=:=Pid])).

%%--------------------------------------------------------------------
%% @doc Find all list
%% @spec lookall() -> {List} | {error, not_found}
%% @end
%%--------------------------------------------------------------------
lookall() ->
    do(qlc:q([[X#socket_to_pid.pid,X#socket_to_pid.socket_type] || X <- mnesia:table(socket_to_pid)])).

%%--------------------------------------------------------------------
%% @doc Delete an element by pid from the registrar.
%% @spec delete(Pid) -> void()
%% @end
%%--------------------------------------------------------------------
delete(Pid) ->
    try
        [#socket_to_pid{} = Record] = mnesia:dirty_read(socket_to_pid, Pid, #socket_to_pid.pid),
        mnesia:dirty_delete_object(Record)
    catch
        _C:_E -> ok
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
dynamic_db_init([]) ->
    delete_schema(),
    {atomic, ok} = mnesia:create_table(socket_to_pid, [{attributes, record_info(fields, socket_to_pid)}]),
    {atomic, ok} = mnesia:create_table(user_info,[{attributes, record_info(fields,user_info)}]), 
    ok;
dynamic_db_init(CacheNodes) ->
    delete_schema(),
    add_extra_nodes(CacheNodes).

%% deletes a local schema.
delete_schema() ->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start().

add_extra_nodes([Node|T]) ->
    case mnesia:change_config(extra_db_nodes, [Node]) of
        {ok, [Node]} ->
            _Res1 = mnesia:add_table_copy(socket_to_pid, node(), ram_copies),
            Tables = mnesia:system_info(tables),
            mnesia:wait_for_tables(Tables, ?WAIT_FOR_TABLES);
        _ ->
            add_extra_nodes(T)
    end.

do(Query) ->
    F = fun() -> qlc:e(Query) end,
    {atomic, Value} = mnesia:transaction(F),
    Value.
