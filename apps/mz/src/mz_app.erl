%%%-------------------------------------------------------------------
%% @doc mz public API
%% @end
%%%-------------------------------------------------------------------

-module(mz_app).

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/sequences/create", create_sequence_handler, []}]}
    ]),
    {ok, _} = cowboy:start_http(mz_listener, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    mz_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
