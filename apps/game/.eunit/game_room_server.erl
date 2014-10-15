-module(game_room_server).

-export([start_link/3]).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-export([delete/1, update_room_maxuser/2,
	 update_room_pass/2,user_jion_room/2,user_leave_room/2]).
%% tick erver time
-define (TICKTIME, 1000).
-define (MAX_USER,4).

-record(state,
	{room_name, create_time, room_ower,
	 room_password = undefined, max_user=?MAX_USER,room_user_list=[],timerref=undefined,timer_count=0}).

start_link(RoomName, RoomPass, RoomOwer) ->
    gen_server:start_link(?MODULE,
			  [RoomName, RoomPass, RoomOwer], []).

delete(Pid) -> gen_server:cast(Pid, destroy).

update_room_pass(RooomPid, PassWord) ->
    gen_server:call(RooomPid, {update_room_pass, PassWord}).

update_room_maxuser(RoomPid, MaxUser) ->
    gen_server:call(RoomPid,
		    {update_room_maxuser, MaxUser}).

user_jion_room(RoomPid,UserPid)->
	gen_server:call(RoomPid, {user_jion_room,UserPid}).   

user_leave_room(RoomPid,UserPid)->
	gen_server:call(RoomPid, {user_leave_room,UserPid}). 


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
 %% userjion room     
handle_call({user_jion_room,UserPid},_From,State=#state{room_user_list=RoomUserList})->
    io:format("~p~n", [RoomUserList]), 
    NewRoomUserList = [UserPid|RoomUserList],
    Reply = case erlang:length(NewRoomUserList)==1 of 
		true->
		    {ok,TimerRef} = start_timer_tick(),
		    {reply,ok,State#state{room_user_list=NewRoomUserList,timerref=TimerRef}};
		false ->
		    {reply,ok,State#state{room_user_list=NewRoomUserList}}
	    end,  
    Reply;	
%% user leave room
handle_call({user_leave_room,UserPid},_From,State=#state{room_user_list=RoomUserList})->
	NewRoomUserList = lists:delete(UserPid, RoomUserList),
    Reply = case erlang:length(NewRoomUserList)=:=0 of
    		true->
    			{stop,normal,State};
    		false->
    			{reply,ok,State#state{room_user_list=NewRoomUserList}}
    		end,
    Reply;	

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.



handle_cast(destroy, State) -> {stop, normal, State};

handle_cast(_Msg, State) -> {noreply, State}.
handle_info({timer_tick,_Message},State=#state{timer_count=Count})->
    io:format("~p~p~n", [self(),Count]),
    {noreply,State#state{timer_count=Count+1}};

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, State=#state{timerref=TimerRef}) ->
	%% close timerref
	if
		TimerRef=/=undefined ->
			timer:cancel(TimerRef) 
	end,
    error_logger:info_msg("Module is: ~p,Line is: ~p Message is: ~p",
			  [?MODULE, ?LINE, "terminate"]),
    ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%private

start_timer_tick(Time,Message)->
    timer:send_interval(Time,Message).

start_timer_tick(Message)->
    start_timer_tick(?TICKTIME,{timer_tick,Message}).	 

start_timer_tick()->
    start_timer_tick(tick).	

