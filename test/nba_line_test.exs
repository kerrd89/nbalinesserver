defmodule NbaLineTest do
  use NbaLinesServer.RepoCase

  describe "get_nba_lines/0" do
    test "returns an empty array if no nba_lines exist" do
      assert NbaLine.Api.get_nba_lines() == []
    end
  end

  describe "create_nba_line/1" do
    test "returns an error if missing params" do
      {:ok, nba_game} = NbaGame.Api.create_nba_game(%{
        "date" => Date.utc_today(),
        "home_team" => "cavs",
        "away_team" => "bulls"
      })

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
      {:ok, nba_game} = NbaGame.Api.create_nba_game(%{
        "date" => Date.utc_today(),
        "home_team" => "cavs",
        "away_team" => "bulls"
      })

      params = %{
        "nba_game_id" => nba_game.id,
        "user_id" => 1,
        "line" => -5,
        "bet" => true
      }

      {:ok, nba_line} = NbaLine.Api.create_nba_line(params)

      assert nba_line.nba_game_id == nba_game.id
    end
  end
end