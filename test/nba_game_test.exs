defmodule NbaGameTest do
  use NbaLinesServer.RepoCase

  describe "get_nba_games_by_date/1" do
    test "returns an empty array if no nba_lines exist" do
      today = Date.utc_today()
      assert NbaGame.Api.get_nba_games_by_date(today) == []
    end
  end

  describe "create_nba_game/1" do
    test "returns an error if missing params" do
      {:error, message} = NbaGame.Api.create_nba_game(%{})

      assert message == [date: {"can't be blank", [validation: :required]}, home_team: {"can't be blank", [validation: :required]}, away_team: {"can't be blank", [validation: :required]}]
    end

    test "returns no error if no missing params" do
      today = Date.utc_today()
      home_team = "cavs"
      away_team = "bulls"

      params = %{
        "date" => today,
        "home_team" => home_team,
        "away_team" => away_team
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      assert nba_game.date == today
      assert nba_game.home_team == home_team
      assert nba_game.away_team == away_team
    end
  end

  describe "complete_nba_game/1" do
    test "returns an error if missing params" do
      today = Date.utc_today()
      home_team = "cavs"
      away_team = "bulls"

      params = %{
        "date" => today,
        "home_team" => home_team,
        "away_team" => away_team
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      # not passing required nba_game_id
      complete_params = %{}

      {:error, message} = NbaGame.Api.complete_nba_game(complete_params)

      assert message == "nba_game_id invalid"

      # not passing valid nba_game_id
      complete_params = %{"nba_game_id" => 1000}

      {:error, message} = NbaGame.Api.complete_nba_game(complete_params)

      assert message == "nba_game_id invalid"

      # not passing score
      complete_params = %{"nba_game_id" => nba_game.id}

      {:error, message} = NbaGame.Api.complete_nba_game(complete_params)

      assert message == [
        home_team_score: {"can't be blank", [validation: :required]},
        away_team_score: {"can't be blank", [validation: :required]}
      ]
    end

    test "returns a success tuple if given valid params" do
      today = Date.utc_today()
      home_team = "cavs"
      away_team = "bulls"
      home_team_score = 102
      away_team_score = 100

      params = %{
        "date" => today,
        "home_team" => home_team,
        "away_team" => away_team
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      complete_params = %{
        "nba_game_id" => nba_game.id,
        "home_team_score" => home_team_score,
        "away_team_score" => away_team_score
      }

      {:ok, completed_nba_game} = NbaGame.Api.complete_nba_game(complete_params)

      assert completed_nba_game.date == today
      assert completed_nba_game.home_team == home_team
      assert completed_nba_game.home_team_score == home_team_score
      assert completed_nba_game.away_team == away_team
      assert completed_nba_game.away_team_score == away_team_score
    end
  end
end