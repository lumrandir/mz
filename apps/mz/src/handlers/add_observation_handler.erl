-module(add_observation_handler).

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
  {ok, Body, Req2} = cowboy_req:body(Req),
  #{<<"sequence">> := SequenceId} = jsx:decode(Body, [return_maps]),
  Resp = case sequence_exists(SequenceId) of
    {ok, found} -> process_observation_ok_json();
    _            -> unknown_sequence_error_json()
  end,    
  Req3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Req2),
  Req4 = cowboy_req:set_resp_body(Resp, Req3),
  {true, Req4, State}.
  
%%% Private
process_observation_ok_json() ->
  undefined.
  
sequence_exists(SequenceId) ->
  case ets:member(observations, SequenceId) of
    true -> {ok, found};
    _    -> {error, not_found}
  end.
  
unknown_sequence_error_json() ->
  jsx:encode([{<<"status">>, <<"error">>}, {<<"msg">>, <<"The sequence isn't found">>}]).