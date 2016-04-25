-module(create_sequence_handler).

-export([
  init/3,
  content_types_accepted/2,
  allowed_methods/2,
  from_json/2
]).

init(_Transport, _Req, []) ->
  {upgrade, protocol, cowboy_rest}.

content_types_accepted(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, []}, from_json}
  ], Req, State}.

allowed_methods(Req, State) ->
  {[<<"POST">>], Req, State}.

from_json(Req, State) ->
  Req2 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Req),
  Resp = sequence_ok_json(),
  Req3 = cowboy_req:set_resp_body(Resp, Req2),
  {true, Req3, State}.

%%% Private
sequence_ok_json() ->
  SequenceId = list_to_binary(uuid:to_string(uuid:uuid1())),
  ets:insert(observations, {SequenceId, []}),
  jsx:encode([
    {<<"status">>, <<"ok">>},
    {<<"response">>,
      jsx:encode([{<<"sequence">>, SequenceId}])
    }
  ]).

