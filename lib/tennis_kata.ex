defmodule TennisKata do

end

defmodule TennisMatch do
    @point_scores  [:love, :fifteen, :thirty, :forty]
    @point_endgame_states  [:deuce, :p1_advantage, :p2_advantage]
    @players [:p1, :p2]
    defstruct [match_type: :nil, point: {:love, :love}, match_status: :normal]

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

        cond  do
            {:p1, {:love, _ }} == {ball_winner, current_point} -> {:fifteen, p2_score}
            {:p2, {_, :love}} == {ball_winner, current_point} -> {p1_score, :fifteen}
            {:p1, {:fifteen, _ }} =  {ball_winner, current_point} -> {:thirty, p2_score}
            {:p2, {_, :fifteen}} = {ball_winner, current_point} -> {p1_score, :thirty}
            {:p1, {:thirty, _ }} = {ball_winner, current_point} -> {:forty, p2_score}
            {:p1, {:thirty, :forty}} = {ball_winner, current_point} -> :deuce
            {:p2, { _ , :thirty}} = {ball_winner, current_point} -> {p1_score, :forty}
            {:p2, {:forty, :thirty}} = {ball_winner, current_point} -> :deuce
            {:p1, {:forty, _ }} = {ball_winner, current_point} -> :game_p1
            {:p2, {_, :forty}} = {ball_winner, current_point} -> :game_p2
        end
    end

end
