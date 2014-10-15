-module(game_user_server).

-export([start_link/2]).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-export([delete/1, update_money/2, get_money/1]).

-record(state,
	{user_id, user_name, user_moeny = 0, login_time}).

start_link(UserID, UserName) ->
    gen_server:start_link(?MODULE,
			  [UserID, UserName], []).

delete(UserPid) -> gen_server:cast(UserPid, destroy).

update_money(UserPid, Money) ->
    gen_server:call(UserPid, {update_money, Money}).

get_money(UserPid) ->
    gen_server:call(UserPid, {get_money}).

init([UserID, UserName]) ->
    {ok,
     #state{user_id = UserID, user_name = UserName,
	    login_time = calendar:local_time()}}.

handle_call({update_money, Money}, _From, State) ->
    {reply, ok, State#state{user_moeny = Money}};
handle_call({get_money}, _From,
	    State = #state{user_moeny = UserMoney}) ->
    {reply, {ok, UserMoney}, State};
handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(destroy, State) -> {stop, normal, State};
handle_cast(_Msg, State) -> {noreply, State}.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.


