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

    test "Should get next point score" do



        actual = TennisMatch.next_point_score(:p1, {:love, :love })
        assert actual == {:fifteen, :love}
        actual = TennisMatch.next_point_score(:p2, {:love, :love })
        assert actual == {:love, :fifteen}
        IO.IO.inspect actual
        actual = TennisMatch.next_point_score(:p1, {:thirty, :forty })
        assert actual == :deuce
        actual = TennisMatch.next_point_score(:p2, {:forty, :thirty })
        assert actual == :deuce



        actual = TennisMatch.next_point_score(:p1, :deuce)
        assert actual == :p1_advantage
        actual = TennisMatch.next_point_score(:p2, :deuce)
        assert actual == :p2_advantage
        actual = TennisMatch.next_point_score(:p1, :p1_advantage)
        assert actual == :game_p1
        actual = TennisMatch.next_point_score(:p2, :p2_advantage)
        assert actual == :game_p2
        actual = TennisMatch.next_point_score(:p1, :p2_advantage)
        assert actual == :deuce
        actual = TennisMatch.next_point_score(:p2, :p1_advantage)
        assert actual == :deuce
    end

    test "Should not be able to get next point score" do
        catch_error TennisMatch.next_point_score(:p1, {:forty, :forty})
        catch_error TennisMatch.next_point_score(:p4, {:forty, :forty})
        catch_error TennisMatch.next_point_score(:p1, {:forty, :random})
        catch_error TennisMatch.next_point_score(:p2, {:ramdp, :forty})
        catch_error TennisMatch.next_point_score(:p1, {:dsgjdgklsj})
        catch_error TennisMatch.next_point_score(:p1, {:forty, :thiry, :fifteen})
        catch_error TennisMatch.next_point_score(:p1, {:fifteen})
    end
end
