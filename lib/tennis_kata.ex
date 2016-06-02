defmodule TennisKata do
end

defmodule Game do
    defstruct [score: {:love, :love}]
    @scores [:love, :fifteen, :thirty, :forty]
    @endgame_scores [:deuce, :advantage_p1, :advantage_p2]
    @win_states [:game_p1, :game_p2]

    def win_states, do: @win_states

    def get_next_state(ball_winner, current_game = %Game{})
    do
        unless ball_winner in TennisMatch.players do
            raise ArgumentError, message: "ball_winner #{ball_winner} not allowed"
        end
        new_score = next_game_state(ball_winner, current_game.score)
        %{current_game | score: new_score}
    end

    defp next_game_state(ball_winner, current_score) when current_score in @endgame_scores
    do
        unless ball_winner in TennisMatch.players do
            raise ArgumentError, message: "ball_winner #{ball_winner} not allowed"
        end

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

    defp next_game_state(ball_winner, current_score) when
    is_tuple(current_score)
    and tuple_size(current_score) == 2
    and elem(current_score, 0) in @scores
    and elem(current_score, 1) in @scores
    and current_score != {:forty, :forty}
    do
        {p1_score, p2_score} = current_score
        params = {ball_winner, current_score}

        case params do
            {:p1, {:love, _ }} -> {:fifteen, p2_score}
            {:p2, {_ , :love}} -> {p1_score, :fifteen}
            {:p1, {:fifteen, _ }} -> {:thirty, p2_score}
            {:p2, {_, :fifteen}} -> {p1_score, :thirty}
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


defmodule TennisSet do
    @status_states [:normal, :tiebreak, :set_p1, :set_p2 ]
    defstruct [status: :normal, score: {0,0}, tiebreak_score: :nil]

    def get_next_state(game_winner, %TennisSet{status: :normal} = current_set)
    do
        unless game_winner in Game.win_states do
            raise ArgumentError, message: "game_winner #{game_winner} not allowed"
        end


        new_score = get_next_score(game_winner, current_set.score)

        case new_score do
            {6,6} -> %{current_set | status: :tiebreak, score: new_score, tiebreak_score: {0,0}}
            :set_p1 -> %{current_set | status: new_score}
            :set_p2 -> %{current_set | status: new_score}
            _ -> %{current_set | score: new_score}
        end
    end

    defp get_next_score(game_winner, {p1_score, p2_score} = score) when
    p1_score <= 6
    and p1_score >= 0
    and p2_score <= 6
    and p2_score >= 0
    and game_winner in [:game_p1, :game_p2]
    do
        cond do
            game_winner == :game_p1 and p1_score == 6 and p2_score < 6 -> :set_p1
            game_winner == :game_p2 and p2_score == 6 and p1_score < 6 -> :set_p2
            game_winner == :game_p1 and p1_score < 6 and p2_score < 6 -> {p1_score + 1, p2_score}
            game_winner == :game_p2 and p1_score < 6 and p2_score < 6 -> {p1_score. p2_score + 1}
        end

    end
end

defmodule TennisMatch do
    @point_scores  [:love, :fifteen, :thirty, :forty]
    @point_endgame_states  [:deuce, :p1_advantage, :p2_advantage]
    @players [:p1, :p2]

    @match_states [:normal, :tiebreak, :match_p1, :match_p2]
    defstruct [match_type: :nil, point: {:love, :love}, match_state: :normal, points: {0,0}, sets: [{0,0}], current_set: 1, tiebreak: :nil]

    def players, do: @players

    def start_match(match_type) when match_type == :best_of_three_sets or match_type == :best_of_five_sets do
        %TennisMatch{match_type: match_type }
    end

    def point(p1_score, p2_score)
    when p1_score in @point_scores and p2_score in @point_scores
     and not (p1_score == :forty and p2_score == :forty)
     do
         {p1_score, p2_score}
     end

    def point(:deuce), do: :deuce
    def point(:p1_advantage), do: :p1_advantage
    def point(:p2_advantage), do: :p2_advantage

    def next_point_score(ball_winner, current_point)
    when ball_winner in @players and current_point in @point_endgame_states
     do
         params = {ball_winner, current_point}
         case params do
             {:p1, :deuce} -> :p1_advantage
             {:p2, :deuce} -> :p2_advantage
             {:p1, :p1_advantage} -> :game_p1
             {:p2, :p2_advantage} -> :game_p2
             {:p1,:p2_advantage} -> :deuce
             {:p2,:p1_advantage} -> :deuce
         end
    end

    def next_point_score(ball_winner, current_point)
    when is_tuple(current_point)
    and ball_winner in @players
    and tuple_size(current_point) == 2
    and elem(current_point, 0) in @point_scores
    and elem(current_point, 1) in @point_scores
    and current_point != {:forty, :forty}
    do
        {p1_score, p2_score} = current_point
        params = {ball_winner, current_point}

        case params do
            {:p1, {:love, _ }} -> {:fifteen, p2_score}
            {:p2, {_ , :love}} -> {p1_score, :fifteen}
            {:p1, {:fifteen, _ }} -> {:thirty, p2_score}
            {:p2, {_, :fifteen}} -> {p1_score, :thirty}
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

    def next_match_state(ball_winner,  %TennisMatch{match_state: :normal} = tennis_match )
    when ball_winner in @players do

        point_state = next_point_score(ball_winner, tennis_match.point)

    end

    def  update_match_state(set_state, tennis_match = %TennisMatch{}) when
    is_tuple(set_state)
    and tuple_size(set_state) == 2 do
        if set_state == {6,6} do
            %{tennis_match | match_state: :tiebreak}
        end
    end

    def update_match_state(:set_p1, tennis_match = %TennisMatch{}) do



    end
end
