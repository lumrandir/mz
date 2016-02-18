-module(create_sequence_handler).

-export([
    init/3,
    content_types_provided/2,
    to_text/2
]).

init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.
    
content_types_provided(Req, State) ->
    {[
        {{<<"text">>, <<"plain">>, []}, to_text}
    ], Req, State}.
    
to_text(Req, State) ->
    SequenceId = uuid:to_string(uuid:uuid1()),
    {list_to_binary(SequenceId), Req, State}.
    