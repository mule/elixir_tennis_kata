defmodule TennisKata.Set.Test do
    require Logger
    use ExUnit.Case
    doctest TennisKata.Set

    test "Should only change the game score within the set" do
        test_set = %TennisKata.Set{}
        expected = %{test_set | current_game: %TennisKata.Game{ score: {:fifteen, :love }}}

        actual = TennisKata.Set.get_next_state(:p1, test_set)
        assert expected == actual

        actual = TennisKata.Set.get_next_state(:p1, actual)
        actual = TennisKata.Set.get_next_state(:p1, actual)
        actual = TennisKata.Set.get_next_state(:p1, actual)
    end

    test "Should change the set score so that player 1 wins a point" do

            test_set = %TennisKata.Set{}
            expected = %{test_set | score: {1,0}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            actual = play_ball(test_set, :p1, 4)
            assert expected == actual
    end

    test "Should change the set score so that player 1 wins a set" do

            test_set = %TennisKata.Set{}
            expected = %{test_set | status: :set_p1, score: {6,0}, current_game: %TennisKata.Game{ score: :game_p1}}
            actual = play_ball(test_set, :p1, 4*6)
            assert expected == actual
            IO.inspect(actual)
    end

    test "Should change the set score so that player 2 wins a point" do

            test_set = %TennisKata.Set{}
            expected = %{test_set | score: {0,1}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            actual = play_ball(test_set, :p2, 4)
            assert expected == actual
    end

    test "Should change the set score so that player 2 wins a set" do

            test_set = %TennisKata.Set{}
            expected = %{test_set | status: :set_p2, score: {0,6}, current_game: %TennisKata.Game{ score: :game_p2}}
            actual = play_ball(test_set, :p2, 4*6)
            assert expected == actual
    end

    test "Should change the set score so that player 1 wins 7-5" do
            test_set = %TennisKata.Set{score: {5,5}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            expected = %{test_set | status: :set_p1, score: {7,5}, current_game: %TennisKata.Game{ score: :game_p1}}
            actual = play_ball(test_set, :p1, 4*2)
            assert expected == actual
    end

    test "Should change the set score so that player 2 wins 5-7" do
            test_set = %TennisKata.Set{score: {5,5}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            expected = %{test_set | status: :set_p2, score: {5,7}, current_game: %TennisKata.Game{ score: :game_p2}}
            actual = play_ball(test_set, :p2, 4*2)
            assert expected == actual
    end

    test "Should change the set status to tiebreak from 5-6" do
            test_set = %TennisKata.Set{score: {5,6}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            expected = %{test_set | status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p1}}
            actual = play_ball(test_set, :p1, 4)
            assert expected == actual
    end

    test "Should change the set status to tiebreak from 6-5" do
            test_set = %TennisKata.Set{score: {6,5}, current_game: %TennisKata.Game{ score: {:love, :love }}}
            expected = %{test_set | status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p2}}
            actual = play_ball(test_set, :p2, 4)
            assert expected == actual
    end

    test "Should end the set when player 1 wins tiebreak" do
            test_set = %TennisKata.Set{status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p1}}
            expected = %{test_set | status: :set_p1, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p1}, tiebreak_score: {7,0}}
            actual = play_ball(test_set, :p1, 7)
            assert expected == actual
    end

    test "Should end the set when player 2 wins tiebreak" do
            test_set = %TennisKata.Set{status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p2}}
            expected = %{test_set | status: :set_p2, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p2}, tiebreak_score: {0,7}}
            actual = play_ball(test_set, :p2, 7)
            assert expected == actual
    end

    test "Should end the set when player 1 gains 2 point advantage in tiebreak" do
            test_set = %TennisKata.Set{status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p1}, tiebreak_score: {100,100}}
            expected = %{test_set | status: :set_p1, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p1}, tiebreak_score: {102,100}}
            actual = play_ball(test_set, :p1, 2)
            assert expected == actual
    end

    test "Should end the set when player 2 gains 2 point advantage in tiebreak" do
            test_set = %TennisKata.Set{status: :tiebreak, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p2}, tiebreak_score: {100,100}}
            expected = %{test_set | status: :set_p2, score: {6,6}, current_game: %TennisKata.Game{ score: :game_p2}, tiebreak_score: {100,102}}
            actual = play_ball(test_set, :p2, 2)
            assert expected == actual
    end

    def play_ball(set_state, ball_winner, n) when n <= 1 do
            TennisKata.Set.get_next_state(ball_winner,set_state)
    end

    def play_ball(set_state, ball_winner, n)  do
        new_set_state = TennisKata.Set.get_next_state(ball_winner,set_state)
        #IO.inspect new_set_state
        play_ball(new_set_state, ball_winner, n-1)
    end

end
