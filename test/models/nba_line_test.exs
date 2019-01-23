defmodule NbaLineTest do
  use NbaLinesServer.RepoCase

  import NbaLinesServer.Factory

  describe "get_nba_lines/0" do
    test "returns an empty array if no nba_lines exist" do
      assert NbaLine.Api.get_nba_lines() == []
    end
  end

  describe "create_nba_line/1" do
    test "returns an error if missing params" do
      nba_game = create(:nba_game)

      {:error, message} = NbaLine.Api.create_nba_line(%{"nba_game_id" => nba_game.id})

      assert message == [line: {"can't be blank", [validation: :required]}, bet: {"can't be blank", [validation: :required]}, user_id: {"can't be blank", [validation: :required]}]
    end

    test "returns error if given no nba_game_id" do
      params = %{
        "user_id" => 1,
        "line" => -5,
        "bet" => true
      }

      {:error, message} = NbaLine.Api.create_nba_line(params)

      assert message == [nba_game_id: {"invalid", [validation: :foreign]}]
    end

    test "returns an error if given an invalid nba_game_id" do
      params = %{
        "nba_game_id" => 12,
        "user_id" => 1,
        "line" => -5,
        "bet" => true
      }

      {:error, message} = NbaLine.Api.create_nba_line(params)

      assert message == [nba_game_id: {"invalid", [validation: :foreign]}]
    end

    test "creates an nba_line when given valid params" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      assert nba_line.nba_game_id == nba_game.id
    end
  end

  describe "complete_nba_line/1" do
    test "home team underdog, bet for the home team, home team wins outright" do
      nba_game = create(:nba_game)
      user = create(:user)


      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of -5, so this result should be 1
      result_params = %{"final_difference" => 14}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 1
    end

    test "home team underdog, bet against the home team, home team wins outright" do
      nba_game = create(:nba_game)
      user = create(:user)


      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of -5, so this result should be 1
      result_params = %{"final_difference" => 14}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team underdog, bet for the home team, home team beats" do
      nba_game = create(:nba_game)
      user = create(:user)


      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of -5, so this result should be 1
      result_params = %{"final_difference" => -4}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 1
    end

    test "home team underdog, bet for home team, home team lost to line" do
      nba_game = create(:nba_game)
      user = create(:user)


      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of -5, so this result should be 1
      result_params = %{"final_difference" => -6}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team underdog, bet against home team, home team beat" do
      nba_game = create(:nba_game)
      user = create(:user)


      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of -5, so this result should be 2
      result_params = %{"final_difference" => -4}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team underdog, bet against home team, home team lost to line" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of -5, so this result should be 2
      result_params = %{"final_difference" => -6}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team underdog, bet against home team, push" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of -5, so this result should be 2
      result_params = %{"final_difference" => -5}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 0
    end

    test "home team underdog, bet for home team, push" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => -5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of -5, so this result should be 2
      result_params = %{"final_difference" => -5}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 0
    end
    
    test "home team favorite, bet for the home team, home team loses outright" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of 5, so this result should be 2
      result_params = %{"final_difference" => -14}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team favorite, bet against the home team, home team loses outright" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of -5, so this result should be 1
      result_params = %{"final_difference" => -14}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 1
    end

    test "home team favorite, bet for the home team, home team beats" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of 5, so this result should be 1
      result_params = %{"final_difference" => 6}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 1
    end

    test "home team favorite, bet against the home team, home team beats" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of 5, so this result should be 2
      result_params = %{"final_difference" => 6}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team favorite, bet for home team, home team lost to line" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of 5, so this result should be 1
      result_params = %{"final_difference" => 4}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 2
    end

    test "home team favorite, bet against home team, home lost to line" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of 5, so this result should be 1
      result_params = %{"final_difference" => 4}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 1
    end

    test "home team favorite, bet against home team, push" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => false
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was false against the line of 5, so this result should be 0
      result_params = %{"final_difference" => 5}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 0
    end

    test "home team favorite, bet for home team, push" do
      nba_game = create(:nba_game)
      user = create(:user)

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => user.id,
        "line" => 5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      # bet was true against the line of 5, so this result should be 0
      result_params = %{"final_difference" => 5}

      {:ok, result_nba_line} = NbaLine.Api.complete_nba_line(nba_line, result_params)
      assert result_nba_line.result == 0
    end
  end

  describe "process_bets/1" do
    test "returns the count of bets processed, 0 if none processed" do
      nba_game = create(:completed_nba_game)

      # TODO: add statistics about each game to each game
      {:ok, process_count} = NbaLine.Api.process_bets(nba_game)

      assert process_count == 0
    end

    test "returns the count of bets processed and processes correctly" do
      nba_game = create(:completed_nba_game)
      user = create(:user)
      _nba_line = create(:nba_line, %{nba_game: nba_game, user: user})

      {:ok, process_count} = NbaLine.Api.process_bets(nba_game)

      assert process_count == 1

      NbaLine.Api.get_nba_lines() |> Enum.each(fn(nba_line) ->
        # default line -5, default diff +2
        assert nba_line.result == 1
      end)
    end
  end
end