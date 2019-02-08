defmodule NbaGameTest do
  use NbaLinesServer.RepoCase

  use ExVCR.Mock

  import NbaLinesServer.Factory

  setup do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
    :ok
  end

  describe "get_nba_games_by_date/1" do
    test "returns an empty array if no nba_lines exist" do
      today = Date.utc_today()
      assert NbaGame.Api.get_nba_games_by_date(today) == []
    end
  end

  describe "create_nba_game/1" do
    test "returns an error if missing params" do
      {:error, message} = NbaGame.Api.create_nba_game(%{})

      assert message == [date: {"can't be blank", [validation: :required]}, home_team: {"can't be blank", [validation: :required]}, away_team: {"can't be blank", [validation: :required]}, start_time: {"can't be blank", [validation: :required]}]
    end

    test "returns no error if no missing params" do
      today = Date.utc_today()
      home_team = "cavs"
      away_team = "bulls"

      params = %{
        "date" => today,
        "home_team" => home_team,
        "away_team" => away_team,
        "start_time" => NaiveDateTime.utc_now()
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      assert nba_game.date == today
      assert nba_game.home_team == home_team
      assert nba_game.away_team == away_team
    end
  end

  describe "update_nba_game/1" do
    test "returns an error if missing params" do
      today = Date.utc_today()
      home_team = "cavs"
      away_team = "bulls"

      params = %{
        "date" => today,
        "home_team" => home_team,
        "away_team" => away_team,
        "start_time" => NaiveDateTime.utc_now()
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      # not passing required nba_game_id
      complete_params = %{}

      {:error, message} = NbaGame.Api.update_nba_game(complete_params)

      assert message == "nba_game_id invalid"

      # not passing valid nba_game_id
      complete_params = %{"nba_game_id" => 1000}

      {:error, message} = NbaGame.Api.update_nba_game(complete_params)

      assert message == "nba_game_id invalid"

      # not passing score
      complete_params = %{"nba_game_id" => nba_game.id}

      {:error, message} = NbaGame.Api.update_nba_game(complete_params)

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
        "away_team" => away_team,
        "start_time" => NaiveDateTime.utc_now()
      }

      {:ok, nba_game} = NbaGame.Api.create_nba_game(params)

      update_params = %{
        "nba_game_id" => nba_game.id,
        "home_team_score" => home_team_score,
        "away_team_score" => away_team_score,
        "period" => 3,
        "clock" => "00:02"
      }

      {:ok, updated_nba_game} = NbaGame.Api.update_nba_game(update_params)

      assert updated_nba_game.date == today
      assert updated_nba_game.home_team == home_team
      assert updated_nba_game.home_team_score == home_team_score
      assert updated_nba_game.away_team == away_team
      assert updated_nba_game.away_team_score == away_team_score
      assert updated_nba_game.period == 3
      assert updated_nba_game.clock == "00:02"
      refute updated_nba_game.completed

      complete_params = %{
        "nba_game_id" => nba_game.id,
        "home_team_score" => home_team_score,
        "away_team_score" => away_team_score,
        "period" => 4,
        "clock" => "",
        "is_finished?" => true
      }

      {:ok, completed_nba_game} = NbaGame.Api.update_nba_game(complete_params)

      assert completed_nba_game.date == today
      assert completed_nba_game.home_team == home_team
      assert completed_nba_game.home_team_score == home_team_score
      assert completed_nba_game.away_team == away_team
      assert completed_nba_game.away_team_score == away_team_score
      assert completed_nba_game.completed
      assert completed_nba_game.clock == nil
      assert completed_nba_game.period == 4
    end

    test "returns processes any associated nba_lines" do
      {year, month, day} = Date.utc_today() |> Date.to_erl()
      past_date = {year - 1, month, day} |> Date.from_erl!()
      nba_game = create(:nba_game, %{date: past_date})
      user = create(:user)
      _nba_line = create(:nba_line, %{nba_game: nba_game, user: user})

      home_team_score = 102 
      away_team_score = 100

      complete_params = %{
        "nba_game_id" => nba_game.id,
        "home_team_score" => home_team_score,
        "away_team_score" => away_team_score,
        "is_finished?" => true
      }

      {:ok, completed_nba_game} = NbaGame.Api.update_nba_game(complete_params)

      NbaLine.Api.get_lines_for_game(completed_nba_game.id)
      |> Enum.each(fn(nba_line) -> assert nba_line.result end)
    end
  end

  describe "get_uncompleted_nba_game_dates/0" do
    test "returns array of dates with uncompleted nba dates" do
      {year, month, day} = Date.utc_today() |> Date.to_erl()
      past_date = {year - 1, month, day} |> Date.from_erl!()

      create(:nba_game, %{date: past_date})
      create(:nba_game, %{home_team: "CHA", away_team: "SAS", date: past_date})

      assert NbaGame.Api.get_uncompleted_nba_game_dates() == [past_date]
    end

    test "should not return uncompleted dates in the future" do
      {year, month, day} = Date.utc_today() |> Date.to_erl()
      future_date = {year + 1, month, day} |> Date.from_erl!()

      create(:nba_game, %{date: future_date})

      assert NbaGame.Api.get_uncompleted_nba_game_dates() == []
    end

    test "returns array of multiple dates with uncompleted nba dates" do
      some_time_ago = Date.from_erl!({2019, 1, 16})
      long_time_ago = Date.from_erl!({2018, 12, 12})

      create(:nba_game, %{date: some_time_ago})
      create(:nba_game, %{date: long_time_ago})

      assert NbaGame.Api.get_uncompleted_nba_game_dates() == [long_time_ago, some_time_ago]
    end
  end

  describe "handle complete nba_games_by_date/1" do
    @tag api: true
    test "returns a success tuple with the count of games completed" do
      use_cassette "get_nba_games_jan_16" do
        past_date = Date.from_erl!({2019, 1, 16})

        {:ok, games_created} = NbaGame.Api.handle_create_nba_games_by_date(past_date)

        assert games_created == 8
        assert Enum.count(NbaGame.Api.get_uncompleted_nba_games_by_date(past_date)) == 8

        {:ok, games_updated} = NbaGame.Api.handle_update_nba_games_by_date(past_date)

        assert games_updated == 8
      end
    end
  end

  describe "add_event_id/2" do
    test "adds an event_id to an game if one is missing" do
      event_id = "tjealdkjgflakfd"
      nba_game = create(:nba_game, event_id: nil)

      assert is_nil(nba_game.event_id)

      {:ok, updated_nba_game} = NbaGame.Api.add_event_id(nba_game, event_id)

      assert updated_nba_game.event_id == event_id
    end
  end
end