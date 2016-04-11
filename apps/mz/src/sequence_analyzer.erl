-module(sequence_analyzer).

-export([analyze/2]).

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

analyze({L, R}, []) ->
  case possible_values(L, R) of
    []      -> {error, undefined};
    [Value] -> {found, Value};
    Values  -> {not_found, Values}
  end;
analyze({L, R}, CurrentState) ->
  case precise(CurrentState, possible_values(L, R)) of
    []         -> {error, undefined};
    [Solution] -> {found, Solution};
    State      -> {not_found, State}
  end.

is_compatible({Iprev, EprevL, EprevR}, {Icur, EcurL, EcurR}) ->
  Lprev = maps:get((Iprev div 10), ?Mappings),
  Rprev = maps:get((Iprev rem 10), ?Mappings),
  Lcur = maps:get((Icur div 10), ?Mappings),
  Rcur = maps:get((Icur rem 10), ?Mappings),

  (Icur =:= Iprev - 1) and
    (((Lprev bxor EprevL) band EcurL) =:= 0) and
    (((Rprev bxor EprevR) band EcurR) =:= 0) and
    (((Lcur bxor EcurL) band EprevL) =:= 0) and
    (((Rcur bxor EcurR) band EprevR) =:= 0).

precise(Previous, Current) ->
  lists:filter(
    fun(Cur) ->
      lists:any(fun(Prev) -> is_compatible(Prev, Cur) end, Previous)
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
        true  -> {I + 1, [{I, Value bxor E}|Acc]}
      end
    end, {0, []}, ?PossibleValues
  ),
  Res.

