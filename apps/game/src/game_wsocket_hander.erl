-module(game_wsocket_hander).

-behaviour(cowboy_websocket_handler).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------


%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init({tcp, http}, _Req, _Opts) ->
    game_store:dirty_insert(self(),web),
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, Req, undefined_state}.

%% handle client send msg
websocket_handle({text, Msg}, Req, State) ->
    game_msg_send:send_message_to_all(self(), {text,Msg}),
    {reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};

websocket_handle({binary, Msg}, Req, State) ->
    game_msg_send:send_message_to_all(self(), {binary, Msg}),
    {reply, {binary, Msg}, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

%% handle other pid send msg
websocket_info({timeout, _Ref, Msg}, Req, State) ->
    %%erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, Req, State};

websocket_info({binary,Msg},Req,State)->
    {reply, {text, <<  Msg/binary >>}, Req, State};

websocket_info({text,Msg},Req,State)->
    {reply, {text, Msg}, Req, State};    

websocket_info(_Info, Req, State) ->
    io:format("websocket_info~p~n",[_Info]),
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    game_store:dirty_delete(self()),
    ok.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

