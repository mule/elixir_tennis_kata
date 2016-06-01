defmodule TennisKata do

end

defmodule TennisMatch do
    @point_scores  [:love, :fifteen, :thirty, :forty]
    @point_endgame_states  [:deuce, :p1_advantage, :p2_advantage]
    @players [:p1, :p2]
    @match_states [:normal, :tiebreak, :match_p1, :match_p2]
    defstruct [match_type: :nil, point: {:love, :love}, match_state: :normal, points: {0,0}, sets: [{0,0}], tiebreak: :nil]

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

    def next_match_state(ball_winner, tennis_match = %TennisMatch{} ) when
     ball_winner in @players
     and tennis_match.match_state == :normal do

        point_state = next_point_score(ball_winner, tennis_match.point)
        set_state = next_points_state(point_state, tennis_match.points)
    end

    

    def next_points_state(point_state, points) when
    point_state == :game_p1
    or point_state == :game_p2
    and is_tuple(points)
    and tuple_size(points) == 2
    and elem(points,0) <= 6
    and elem(points,1) <= 6
    and points != {6,6} do
        {p1_score, p2_score} = points

        case point_state do
            :game_p1 -> {p1_score +1, p2_score}
            :game_p2 -> {p1_score, p2_score + 1}
        end
    end


end
