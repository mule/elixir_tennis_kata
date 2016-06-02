defmodule TennisKata.Set do
    require TennisKata.Match
    require TennisKata.Game
    @status_states [:normal, :tiebreak, :set_p1, :set_p2 ]
    defstruct [status: :normal, current_game: %TennisKata.Game{}, score: {0,0}, tiebreak_score: :nil]

    def get_next_state(ball_winner, %TennisKata.Set{status: :normal} = current_set)
    when ball_winner in TennisKata.Match.players
    do
        new_game_state = TennisKata.Game.get_next_state(ball_winner, current_set.current_game)
        new_score = get_next_score(new_game_state.score, current_set.score)

        case new_score do
            {6,6} -> %{current_set | status: :tiebreak, score: new_score, current_game: new_game_state, tiebreak_score: {0,0}}
            :set_p1 -> %{current_set | status: new_score, current_game: new_game_state}
            :set_p2 -> %{current_set | status: new_score, current_game: new_game_state}
            _ -> %{current_set | score: new_score, current_game: new_game_state }
        end
    end

    def get_next_state(ball_winner, %TennisKata.Set{status: :tiebreak} = current_set)
    when ball_winner in TennisKata.Match.players
    do
        new_tiebrake_state = get_next_tiebreak_state(ball_winner, current_set.tiebreak_score)
        {new_set_status, tiebreak_score} = new_tiebrake_state
        %{current_set | status: new_set_status, tiebreak_score: tiebreak_score}
    end

    defp get_next_score(game_state, {p1_score, p2_score} = score) when
    p1_score <= 6
    and p1_score >= 0
    and p2_score <= 6
    and p2_score >= 0
    and game_state in TennisKata.Game.win_states
    do
        cond do
            game_state == :game_p1 and p1_score == 6 and p2_score < 6 -> :set_p1
            game_state == :game_p2 and p2_score == 6 and p1_score < 6 -> :set_p2
            game_state == :game_p1 and p1_score < 6 and p2_score < 6 -> {p1_score + 1, p2_score}
            game_state == :game_p2 and p1_score < 6 and p2_score < 6 -> {p1_score. p2_score + 1}
        end
    end

    defp get_next_score(game_state,  {p1_score, p2_score} = score) when
    p1_score <= 6
    and p1_score >= 0
    and p2_score <= 6
    and p2_score >= 0
    and game_state in TennisKata.Game.endgame_scores
    do
        score
    end

    defp get_next_score({p1_game_score, p2_game_score} = game_state,  {p1_score, p2_score} = score) when
    p1_score <= 6
    and p1_score >= 0
    and p2_score <= 6
    and p2_score >= 0
    and p1_game_score in TennisKata.Game.scores
    and p2_game_score in TennisKata.Game.scores
    do
        score
    end

    defp get_next_tiebreak_state(ball_winner, {p1_score, p2_score} = current_score) when ball_winner in TennisKata.Match.players
    do
        cond do
            ball_winner == :p1 and p1_score == 6 and p2_score <= 5 -> {:set_p1, {p1_score + 1, p2_score}}
            ball_winner == :p2 and p2_score == 6 and p1_score <= 5 -> {:set_p2, {p1_score, p2_score + 1}}
            ball_winner == :p1 and p1_score - p2_score == 0 -> {:tiebreak, {p1_score + 1, p2_score }}
            ball_winner == :p2 and p2_score - p1_score == 0 -> {:tiebreak, {p1_score, p2_score + 1 }}
            ball_winner == :p1 and p1_score < 6 -> {:tiebreak, {p1_score + 1, p2_score }}
            ball_winner == :p2 and p2_score < 6 -> {:tiebreak, {p1_score, p2_score + 1 }}
            ball_winner == :p1 and p1_score >= 6 and p2_score >= 6 and p1_score - p2_score == 1 -> {:set_p1, {p1_score + 1, p2_score }}
        end
    end


end
