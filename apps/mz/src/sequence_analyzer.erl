-module(sequence_analyzer).

-export([analyze/2, resemblence_list/1]).

-define(PossibleValues, [123, 127, 82, 111, 107, 58, 91, 93, 18, 119]).

analyze(CurrentState, NewData) ->
  undefined.
  
resemblence_list(Value) ->
  lists:filter(fun(X) -> Value bor X bxor X =:= 0 end, ?PossibleValues).
    
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