-module(game_login_server).

-export([start_link/0]).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2,
	 handle_info/2, terminate/2, code_change/3]).

-export([login/2, logout/1]).

login(UserID, UserName) ->
    gen_server:call(?MODULE,
		    {login, UserID, UserName}, 3000).

logout(UserID) ->
    gen_server:cast(?MODULE, {logout, UserID}).

start_link() ->
    gen_server:start_link({local, ?MODULE},
			  game_login_server, {}, []).

init({}) -> {ok, undefined}.

handle_call({login, UserID, UserName}, _From, State) ->
    {reply, {ok, success}, State};
handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast({logout, UserID}, State) ->
    {noreply, State};
handle_cast(_Msg, State) -> {noreply, State}.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.


