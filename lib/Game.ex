defmodule TennisKata.Game do
    defstruct [score: {:love, :love}]
    @scores [:love, :fifteen, :thirty, :forty]
    @endgame_scores [:deuce, :advantage_p1, :advantage_p2]
    @win_states [:game_p1, :game_p2]

    defmacro win_states, do: unquote(@win_states)
    defmacro endgame_scores, do: unquote(@endgame_scores)
    defmacro scores, do: unquote(@scores)

    def get_next_state(ball_winner, current_game = %TennisKata.Game{})
    when ball_winner in [:p1, :p2]
    do
        new_score = next_game_state(ball_winner, current_game.score)
        %{current_game | score: new_score}
    end

    defp next_game_state(ball_winner, current_score) when
    current_score in @endgame_scores
    and ball_winner in [:p1, :p2]
    do

        params = {ball_winner, current_score}
            case params  do
            {:p1, :advantage_p1} -> :game_p1
            {:p2, :advantage_p2} -> :game_p2
            {:p1, :advantage_p2} -> :deuce
            {:p2, :advantage_p1} -> :deuce
            {:p1, :deuce} -> :advantage_p1
            {:p2, :deuce} -> :advantage_p2
        end
    end

    defp next_game_state(ball_winner, {p1_score, p2_score} = current_score) when
    p1_score in @scores
    and p2_score in @scores
    and current_score != {:forty, :forty}
    and ball_winner in [:p1, :p2]
    do
        params = {ball_winner, current_score}
        case params do
            {:p1, {:love, _ }} -> {:fifteen, p2_score}
            {:p2, {_ , :love}} -> {p1_score, :fifteen}
            {:p1, {:fifteen, _ }} -> {:thirty, p2_score}
            {:p2, {_, :fifteen}} -> {p1_score, :thirty}
            {:p1, {:thirty, :love }} -> {:forty, :love}
            {:p2, {:love, :thirty }} -> {:love, :forty}
            {:p1, {:thirty, :fifteen }} -> {:forty, :fifteen}
            {:p1, {:thirty, :thirty }} -> {:forty, :thirty}
            {:p1, {:thirty, :forty}} -> :deuce
            {:p2, { :fifteen , :thirty}} -> {:fifteen, :forty}
            {:p2, { :thirty , :thirty}} -> {:thirty, :forty}
            {:p2, {:forty, :thirty}} -> :deuce
            {:p1, {:forty, _ }} -> :game_p1
            {:p2, {_, :forty}} -> :game_p2
        end
    end
end
