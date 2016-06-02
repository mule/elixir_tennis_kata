defmodule TennisKataTest do
    require Logger
    use ExUnit.Case
    doctest TennisKata

    test "start match" do
        actual =  TennisMatch.start_match(:best_of_three_sets)
        assert actual == %TennisMatch{match_type: :best_of_three_sets}
        actual = TennisMatch.start_match(:best_of_five_sets)
        assert actual == %TennisMatch{match_type: :best_of_five_sets}
        IO.inspect actual
    end

    test "start match should not accept random input" do
        catch_error(TennisMatch.start_match(:random))
        catch_error TennisMatch.start_match(1223334234)
    end

    test "should get point score" do
        TennisMatch.point(:love, :fifteen)
    end

    test "Should get next game score" do
        initial_game_state = %Game{}
        expected = %Game{score: {:fifteen, :love}}
        actual = Game.get_next_state(:p1, initial_game_state)
        assert actual == expected

        expected = %Game{score: {:fifteen, :fifteen}}
        actual = Game.get_next_state(:p2, actual)
        assert actual == expected

        expected = %Game{score: :advantage_p1}
        actual = Game.get_next_state(:p1, %Game{score: :deuce})
        assert actual == expected

        expected = %Game{score: :advantage_p2}
        actual = Game.get_next_state(:p2, %Game{score: :deuce})
        assert actual == expected

        expected = %Game{score: :game_p1}
        actual = Game.get_next_state(:p1, %Game{score: :advantage_p1})
        assert actual == expected

        expected = %Game{score: :deuce}
        actual = Game.get_next_state(:p2, %Game{score: :advantage_p1})
        assert actual == expected

        expected = %Game{score: :deuce}
        actual = Game.get_next_state(:p1, %Game{score: :advantage_p2})
        assert actual == expected

        expected = %Game{score: :game_p2}
        actual = Game.get_next_state(:p2, %Game{score: :advantage_p2})
        assert actual == expected

        # actual = TennisMatch.next_point_score(:p1, {:love, :love })
        # assert actual == {:fifteen, :love}
        # actual = TennisMatch.next_point_score(:p2, {:love, :love })
        # assert actual == {:love, :fifteen}
        # actual = TennisMatch.next_point_score(:p1, {:thirty, :forty })
        # assert actual == :deuce
        # actual = TennisMatch.next_point_score(:p2, {:forty, :thirty })
        # assert actual == :deuce
        #
        # actual = TennisMatch.next_point_score(:p1, :deuce)
        # assert actual == :p1_advantage
        # actual = TennisMatch.next_point_score(:p2, :deuce)
        # assert actual == :p2_advantage
        # actual = TennisMatch.next_point_score(:p1, :p1_advantage)
        # assert actual == :game_p1
        # actual = TennisMatch.next_point_score(:p2, :p2_advantage)
        # assert actual == :game_p2
        # actual = TennisMatch.next_point_score(:p1, :p2_advantage)
        # assert actual == :deuce
        # actual = TennisMatch.next_point_score(:p2, :p1_advantage)
        # assert actual == :deuce
    end

    test "Should not be able to get next point score" do
        catch_error Game.get_next_state(:p1, %Game{score: {:forty, :forty}})
        catch_error Game.get_next_state(:p4, %Game{score: {:forty, :forty}})
        catch_error Game.get_next_state(:p1, %Game{score: {:forty, :random}})
        catch_error Game.get_next_state(:p2, %Game{score: {:random, :forty}})
        catch_error Game.get_next_state(:p1, %Game{score: {:ldfsf}})
        catch_error Game.get_next_state(:p1, %Game{score: {:forty, :thirty, :fifteen}})
        catch_error Game.get_next_state(:p1, %Game{score: {:fifteen}})
    end
end
