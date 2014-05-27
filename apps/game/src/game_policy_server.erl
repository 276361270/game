-module(game_policy_server).

-behaviour(gen_server).

-export([start_link/1, load_file/1, reload/0, policy_file/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {filename}).

-define(GENERIC_POLICY_FILE,
        <<"<?xml version=\"1.0\"?>"
         "<!DOCTYPE cross-domain-policy SYSTEM \"/xml/dtds/cross-domain-policy.dtd\">"
         "<cross-domain-policy>"
         "    <allow-access-from domain=\"*\" to-ports=\"*\" />"
         "</cross-domain-policy>">>).

start_link(Filename) -> gen_server:start_link(?MODULE, [Filename], []).

reload() -> gen_server:call(?MODULE, reload, infinity).
load_file(Filename) -> gen_server:call(?MODULE, {load_file, Filename}, infinity).

policy_file() ->
    [{default, Contents}] = ets:lookup(?MODULE, default),
    {ok, Contents}.

init([Filename]) ->
    ?MODULE = ets:new(?MODULE, [protected, {read_concurrency, true}, named_table]),
    ok = load_policy_file(Filename),
    {ok, #state{filename = Filename}}.

handle_call(reload, _From, #state{filename = Filename} = State) ->
    {reply, load_policy_file(Filename), State};
handle_call({load_file, Filename}, _From, State) ->
    {reply, load_policy_file(Filename), State#state{filename = Filename}};
handle_call(_Request, _From, State) ->
    {reply, badarg, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Request, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

load_policy_file(Filename) ->
    {ok, Contents0} =
        case Filename of
            liberal -> {ok, ?GENERIC_POLICY_FILE};
            _       -> file:load_file(Filename)
        end,
    Contents = <<Contents0/binary, 0>>, % null terminate
    true = ets:insert(?MODULE, {default, Contents}),
    ok.
