

defmodule TennisKata.Match do
    @players [:p1, :p2]

    defstruct [match_type: :nil, point: {:love, :love}, match_state: :normal, points: {0,0}, sets: [{0,0}], current_set: 1, tiebreak: :nil]

    defmacro players, do: unquote(@players)

    def start_match(match_type) when match_type == :best_of_three_sets or match_type == :best_of_five_sets do
        %TennisKata.Match{match_type: match_type }
    end


end
