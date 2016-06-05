defmodule TennisKata.Set do
    require TennisKata.Game
    @status_states [:normal, :tiebreak, :set_p1, :set_p2 ]
    defstruct [status: :normal, current_game: %TennisKata.Game{}, score: {0,0}, tiebreak_score: :nil]

    def get_next_state(ball_winner, %TennisKata.Set{status: :normal} = current_set)
    when ball_winner in [:p1, :p2]
    do
        new_game_state = TennisKata.Game.get_next_state(ball_winner, current_set.current_game)
        new_state = get_next_score(new_game_state.score, current_set.score)
        {new_status, new_score} = new_state

        if new_status == :normal and new_score != current_set.score do
            new_game_state = %TennisKata.Game{}
        end

        new_set = %{current_set | status: new_status, score: new_score, current_game: new_game_state}

    end

    def get_next_state(ball_winner, %TennisKata.Set{status: :tiebreak} = current_set)
    when ball_winner in [:p1, :p2]
    do
        new_tiebrake_state = get_next_tiebreak_state(ball_winner, current_set.tiebreak_score)
        {new_set_status, tiebreak_score} = new_tiebrake_state
        %{current_set | status: new_set_status, tiebreak_score: tiebreak_score}
    end

    defp get_next_score(game_state, {p1_score, p2_score} = score) when
    p1_score <= 7
    and p1_score >= 0
    and p2_score <= 7
    and p2_score >= 0
    and game_state in TennisKata.Game.win_states
    do
        cond do
            game_state == :game_p1 and p1_score == 5 and p2_score < 5 -> {:set_p1, {p1_score + 1, p2_score}}
            game_state == :game_p2 and p2_score == 5 and p1_score < 5 -> {:set_p2, {p1_score, p2_score + 1}}
            game_state == :game_p1 and p1_score < 6 and p2_score < 6 -> {:normal, {p1_score + 1, p2_score}}
            game_state == :game_p2 and p1_score < 6 and p2_score < 6 -> {:normal, {p1_score, p2_score + 1}}
            game_state == :game_p1 and p1_score == 5 and p2_score == 6 -> {:tiebreak, {p1_score + 1, p2_score}}
            game_state == :game_p2 and p1_score == 6 and p2_score == 5 -> {:tiebreak, {p1_score, p2_score + 1}}
            game_state == :game_p1 and p1_score == 6 and p2_score == 5 -> {:set_p1, {p1_score + 1, p2_score}}
            game_state == :game_p2 and p1_score == 5 and p2_score == 6 -> {:set_p2, {p1_score, p2_score + 1}}
        end
    end

    defp get_next_score(game_state,  {p1_score, p2_score} = score) when
    p1_score <= 7
    and p1_score >= 0
    and p2_score <= 7
    and p2_score >= 0
    and game_state in TennisKata.Game.endgame_scores
    do
        {:normal, score}
    end

    defp get_next_score({p1_game_score, p2_game_score} = game_state,  {p1_score, p2_score} = score) when
    p1_score <= 7
    and p1_score >= 0
    and p2_score <= 7
    and p2_score >= 0
    and p1_game_score in TennisKata.Game.scores
    and p2_game_score in TennisKata.Game.scores
    do
        {:normal, score}
    end

    defp get_next_tiebreak_state(ball_winner,:nil), do: get_next_tiebreak_state(ball_winner, {0,0})

    defp get_next_tiebreak_state(ball_winner, {p1_score, p2_score} = current_score) when ball_winner in [:p1, :p2]
    do
        cond do
            ball_winner == :p1 and p1_score == 6 and p2_score <= 5 -> {:set_p1, {p1_score + 1, p2_score}}
            ball_winner == :p2 and p2_score == 6 and p1_score <= 5 -> {:set_p2, {p1_score, p2_score + 1}}
            ball_winner == :p1 and p1_score - p2_score == 0 -> {:tiebreak, {p1_score + 1, p2_score }}
            ball_winner == :p2 and p2_score - p1_score == 0 -> {:tiebreak, {p1_score, p2_score + 1 }}
            ball_winner == :p1 and p1_score < 6 -> {:tiebreak, {p1_score + 1, p2_score }}
            ball_winner == :p2 and p2_score < 6 -> {:tiebreak, {p1_score, p2_score + 1 }}
            ball_winner == :p1 and p1_score >= 6 and p2_score >= 6 and p1_score - p2_score == 1 -> {:set_p1, {p1_score + 1, p2_score}}
            ball_winner == :p2 and p1_score >= 6 and p2_score >= 6 and p2_score - p1_score == 1 -> {:set_p2, {p1_score, p2_score + 1}}
        end
    end


end
