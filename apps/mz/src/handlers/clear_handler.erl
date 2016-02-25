-module(clear_handler).

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
  Resp = clear_db_ok_json(),
  Req3 = cowboy_req:set_resp_body(Resp, Req2),
  {true, Req3, State}.
  
%%% Private
clear_db_ok_json() ->
  ets:delete_all_objects(observations),
  list_to_binary("{\"status\": \"ok\", \"response\": \"ok\"}").