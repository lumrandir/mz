-module(sequence_analyzer).

-export([analyze/2, resemblence_list/1, possible_values/2, precise/2, test/2]).

-define(PossibleValues, [119, 18, 93, 91, 58, 107, 111, 82, 127, 123]).
%%% Mappings
%% 0 => 1110111 => 01110111 => 119
%% 1 => 0010010 => 00010010 => 18
%% 2 => 1011101 => 01011101 => 93
%% 3 => 1011011 => 01011011 => 91
%% 4 => 0111010 => 00111010 => 58
%% 5 => 1101011 => 01101011 => 107
%% 6 => 1101111 => 01101111 => 111
%% 7 => 1010010 => 01010010 => 82
%% 8 => 1111111 => 01111111 => 127
%% 9 => 1111011 => 01111011 => 123 
-define(Mappings, #{
  0 => 2#1110111,
  1 => 2#0010010,
  2 => 2#1011101,
  3 => 2#1011011,
  4 => 2#0111010,
  5 => 2#1101011,
  6 => 2#1101111,
  7 => 2#1010010,
  8 => 2#1111111,
  9 => 2#1111011
}).

test(0, Acc) ->
  Acc;
test(V, []) ->
  L = maps:get((V div 10), ?Mappings) bor 2#0010000 bxor 2#0010000,
  R = maps:get((V rem 10), ?Mappings) bor 2#1000000 bxor 2#1000000,
  Acc = possible_values(L, R),
  io:format("~p~n~p~n", [V, Acc]),
  test(V - 1, Acc);
test(V, Acc) ->
  L = maps:get((V div 10), ?Mappings) bor 2#0010000 bxor 2#0010000,
  R = maps:get((V rem 10), ?Mappings) bor 2#1000000 bxor 2#1000000,
  P = possible_values(L, R),
  A = precise(Acc, P),
  io:format("~p~n~p~n~p~n", [V, P, A]),
  test(V - 1, A).  

analyze(CurrentState, NewData) ->
  undefined.

precise(Previous, Current) ->
  lists:filter(
    fun({I, E1, E2}) -> 
      lists:any(fun({Ipr, Epr1, Epr2}) -> (Ipr - 1 =:= I) and (Epr1 band E1 =/= 0) and (Epr2 band E2 =/= 0) end, Previous) 
    end, Current
  ).

possible_values(Left, Right) ->
  LeftList  = resemblence_list(Left),
  RightList = resemblence_list(Right),
  lists:sort([{L1 * 10 + R1, L2, R2} || {L1, L2} <- LeftList, {R1, R2} <- RightList]).
  
resemblence_list(Value) ->
  {_, Res} = lists:foldl(
    fun(E, {I, Acc}) ->
      case Value bor E bxor E =:= 0 of
        false -> {I + 1, Acc};
        true  -> {I + 1, [{I, Value bxor 2#1111111}|Acc]}
      end
    end, {0, []}, ?PossibleValues
  ),
  Res.
    
