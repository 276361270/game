-module(game_tcp_server).

-behaviour(gen_server).

-behaviour(ranch_protocol).

-export([start_link/4]).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-record(state,
	{ref, socket, transport, otp, ip, port, timeref,
	 ping = 0, is_login = false, userpid = undefined}).

start_link(Ref, Socket, Transport, Opts) ->
    gen_server:start_link(?MODULE,
			  [Ref, Socket, Transport, Opts], []).

init([Ref, Socket, Transport, Opts]) ->
    {ok, TimeRef} = timer:send_after(3000, disconnect),
    {ok, {Address, Port}} = inet:peername(Socket),
    {ok,
     #state{ref = Ref, socket = Socket,
	    transport = Transport, otp = Opts, ip = Address,
	    port = Port, timeref = TimeRef},
     0}.

handle_info(timeout,
	    State = #state{ref = Ref, socket = Socket,
			   transport = Transport}) ->
    ok = ranch:accept_ack(Ref),
    ok = Transport:setopts(Socket, [{active, once}]),
    game_store:dirty_insert(self(), tcp),
    {noreply, State};
handle_info({tcp, Socket, Data},
	    State = #state{socket = Socket, transport = Transport,
			   is_login = Is_Login}) ->
    Transport:setopts(Socket, [{active, once}]),
    Replay = case game_pack:unpack_compress(Data) of
	       {ok, Maps} ->
		   case game_pack:get_value("c", Maps) of
		     <<"login">> ->
			 UserID = game_pack:get_value("u", Maps),
			 UserName = game_pack:get_value("n", Maps),
			 {ok, IsLogin, UserPid} = case
						    game_login_server:login(UserID,
									    UserName)
						      of
						    {ok, success} ->
							{ok, Pid} =
							    game_user:new(UserID,
									  UserName),
							{ok, true, Pid};
						    {error, _Msg} ->
							{ok, false, undefined}
						  end,
			 Result = #{<<"c">> => <<"login">>, <<"r">> => IsLogin},
			 {ok, Res} = game_pack:pack_compress(Result),
			 Transport:send(Socket, Res),
			 {noreply,
			  State#state{ping = 1, is_login = IsLogin,
				      userpid = UserPid}};
		     _other ->
			 case Is_Login of
			   true ->
			       {ok, P} = game_pack:pack_compress(Maps),
			       Transport:send(Socket, P),
			       {noreply, State};
			   false -> {stop, normal, State}
			 end
		   end;
	       {error, Error} ->
		   error_logger:error_msg("Module is: ~p,Line is: ~p Message is: ~p",
					  [?MODULE, ?LINE, Error]),
		   {stop, normal, State}
	     end,
    Replay;
handle_info({tcp_closed, _Socket},
	    State = #state{userpid = UserPid}) ->
    game_user:delete(UserPid), {stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
    {stop, Reason, State};
handle_info(timeout, State) -> {stop, normal, State};
handle_info(disconnect,
	    State = #state{ping = Ping, timeref = TimeRef}) ->
    timer:cancel(TimeRef),
    case Ping > 0 of
      true -> {noreply, State};
      false -> {stop, normal, State}
    end;
handle_info(_Info, State) -> {stop, normal, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({text, Data},
	    State = #state{socket = Socket,
			   transport = Transport}) ->
    Transport:send(Socket, msgpack:pack(Data)),
    {noreply, State};
handle_cast({binary, Data},
	    State = #state{socket = Socket,
			   transport = Transport}) ->
    Transport:send(Socket, msgpack:pack(Data)),
    {noreply, State}.

terminate(_Reason, _State) ->
    game_store:dirty_delete(self()), ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.


