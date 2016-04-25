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
  Resp = try
    #{<<"sequence">> := SequenceId, <<"observation">> := Observation} =
      jsx:decode(Body, [return_maps]),
    #{<<"color">> := Color, <<"numbers">> := Numbers} = Observation,
    case sequence_exists(SequenceId) of
      {ok, found} -> process_observation_ok_json(SequenceId, Color, Numbers);
      _           -> unknown_sequence_error_json()
    end
  catch
    error:{badmatch, _} -> invalid_format_error_json()
  end,
  Req3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Req2),
  Req4 = cowboy_req:set_resp_body(Resp, Req3),
  {true, Req4, State}.

%%% Private
process_observation_ok_json(Sequence, Color, Numbers) ->
  [{Sequence, State}] = ets:lookup(observations, Sequence),
  NewState = sequence_analyzer:analyze(Color, Numbers, State),
  ets:update_element(observations, Sequence, {2, NewState}),
  jsx:encode([{<<"status">>, <<"ok">>}, {<<"response">>, NewState}]).

sequence_exists(SequenceId) ->
  case ets:member(observations, SequenceId) of
    true -> {ok, found};
    _    -> {error, not_found}
  end.

invalid_format_error_json() ->
  jsx:encode([{<<"status">>, <<"error">>}, {<<"msg">>, <<"Invalid request format">>}]).

unknown_sequence_error_json() ->
  jsx:encode([{<<"status">>, <<"error">>}, {<<"msg">>, <<"The sequence isn't found">>}]).
