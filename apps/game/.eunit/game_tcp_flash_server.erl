-module(game_tcp_flash_server).

-behaviour(gen_server).

-behaviour(ranch_protocol).

-export([start_link/4]).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-record(state, {ref, socket, transport, otp, timeref}).

start_link(Ref, Socket, Transport, Opts) ->
    gen_server:start_link(?MODULE,
			  [Ref, Socket, Transport, Opts], []).

init([Ref, Socket, Transport, Opts]) ->
    {ok, TimeRef} = timer:send_after(3000, disconnect),
    {ok,
     #state{ref = Ref, socket = Socket,
	    transport = Transport, otp = Opts, timeref = TimeRef},
     0}.

handle_info(timeout,
	    State = #state{ref = Ref, socket = Socket,
			   transport = Transport}) ->
    ok = ranch:accept_ack(Ref),
    ok = Transport:setopts(Socket, [{active, once}]),
    {noreply, State};
handle_info({tcp, Socket, _Data},
	    State = #state{socket = Socket,
			   transport = Transport}) ->
    {ok, File} = game_policy_server:policy_file(),
    Transport:send(Socket, File),
    {stop, normal, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
    {stop, Reason, State};
handle_info(disconnect, State = #state{timeref = TimeRef}) ->
     timer:cancel(TimeRef),
     {stop, normal, State};
handle_info(timeout, State) -> 
    {stop, normal, State};
handle_info(_Info, State) -> 
    {stop, normal, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) -> 
    {noreply, State}.

terminate(_Reason, _State) ->
     ok.

code_change(_OldVsn, State, _Extra) ->
     {ok, State}.


