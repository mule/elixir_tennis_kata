defmodule TennisKata.MatchTest do
    require Logger
    use ExUnit.Case
    doctest TennisKata.Match

    test "start match" do
        actual =  TennisKata.Match.start_match(:best_of_three_sets)
        assert actual == %TennisKata.Match{match_type: :best_of_three_sets}
        actual = TennisKata.Match.start_match(:best_of_five_sets)
        assert actual == %TennisKata.Match{match_type: :best_of_five_sets}
        IO.inspect actual
    end

    test "start match should not accept random input" do
        catch_error(TennisKata.Match.start_match(:random))
        catch_error TennisKata.Match.start_match(1223334234)
    end
end
