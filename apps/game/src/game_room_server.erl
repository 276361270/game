-module(game_room_server).

-export([start_link/3]).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-export([delete/1, update_room_maxuser/2,
	 update_room_pass/2]).

-record(state,
	{room_name, create_time, room_ower,
	 room_password = undefined, max_user = 4}).

start_link(RoomName, RoomPass, RoomOwer) ->
    gen_server:start_link(?MODULE,
			  [RoomName, RoomPass, RoomOwer], []).

delete(Pid) -> gen_server:cast(Pid, destroy).

update_room_pass(RooomPid, PassWord) ->
    gen_server:call(RooomPid, {update_room_pass, PassWord}).

update_room_maxuser(RoomPid, MaxUser) ->
    gen_server:call(RoomPid,
		    {update_room_maxuser, MaxUser}).

init([RoomName, RoomPass, RoomOwer]) ->
    {ok,
     #state{room_name = RoomName, room_password = RoomPass,
	    room_ower = RoomOwer,
	    create_time = calendar:local_time()}}.

handle_call({update_room_pass, PassWord}, _From,
	    State) ->
    {reply, ok, State#state{room_password = PassWord}};
handle_call({update_room_maxuser, MaxUser}, _From,
	    State) ->
    {reply, ok, State#state{max_user = MaxUser}};
handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(destroy, State) -> {stop, normal, State};
handle_cast(_Msg, State) -> {noreply, State}.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) ->
    error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p",
			  [game_room_server, 43, "terminate"]),
    ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.


