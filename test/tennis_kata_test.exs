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
end
