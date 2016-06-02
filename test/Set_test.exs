defmodule TennisKata.Set.Test do
    require Logger
    use ExUnit.Case
    doctest TennisKata.Set

    test "Should get next set state" do
        test_set = %TennisKata.Set{}
        expected = %{test_set | current_game: %TennisKata.Game{ score: {:fifteen, :love }}}

        actual = TennisKata.Set.get_next_state(:p1, test_set)
        assert expected == actual

        actual = TennisKata.Set.get_next_state(:p1, actual)
        actual = TennisKata.Set.get_next_state(:p1, actual)
        actual = TennisKata.Set.get_next_state(:p1, actual)
        IO.inspect(actual)
    end
end
