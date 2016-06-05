

defmodule TennisKata.Match do
    require TennisKata.Set
    @players [:p1, :p2]

    defstruct [match_type: :nil, status: :normal, played_sets: [], current_set: %TennisKata.Set{}]

    defmacro players, do: unquote(@players)

    def start_match(match_type) when match_type == :best_of_three_sets or match_type == :best_of_five_sets do
        %TennisKata.Match{match_type: match_type }
    end

    def get_next_state(ball_winner, current_match) do

        new_set_state = TennisKata.Set.get_next_state(ball_winner, current_match.current_set)
        new_match_state = update_match_status(new_set_state, current_match)

        case {new_set_state.status, new_match_state.status} do
            {:set_p1, :normal} -> %{new_match_state | current_set: %TennisKata.Set{}, played_sets: current_match.played_sets ++ new_set_state }
            {:set_p2, :normal} -> %{new_match_state | current_set: %TennisKata.Set{}, played_sets: current_match. ++ new_set_state }
             _ ->  %{new_match_state | current_set: new_set_state}
        end
    end

    defp update_match_status(%TennisKata.Set{} = set_state, %TennisKata.Match{} = current_match)  do

        won_set_count = Enum.count(current_match.played_sets, fn(set) -> set.status == set_state.status end)

        case {set_state.status, current_match.match_type, won_set_count} do
            {:set_p1, :best_of_three_sets, 2} -> %{current_match | status: :match_p1}
            {:set_p1, :best_of_five_sets, 3} -> %{current_match | status: :match_p1}
            {:set_p2, :best_of_three_sets, 2} -> %{current_match | status: :match_p2}
            {:set_p2, :best_of_five_sets, 3} -> %{current_match | status: :match_p2}
            _ -> current_match
        end
    end
end
