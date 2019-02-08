defmodule NbaOfferedLineTest do
  use NbaLinesServer.RepoCase
  use ExVCR.Mock

  import NbaLinesServer.Factory

  setup do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
    :ok
  end

  describe "create_nba_offered_line/1" do
    test "returns an error if missing params" do
      nba_game = create(:nba_game)

      {:error, message} = NbaOfferedLine.Api.create_nba_offered_line(%{"nba_game_id" => nba_game.id})

      assert message == [line: {"can't be blank", [validation: :required]}]
    end

    test "returns error if given no nba_game_id" do
      params = %{
        "line" => -5.2,
      }

      {:error, message} = NbaOfferedLine.Api.create_nba_offered_line(params)

      assert message == [nba_game_id: {"invalid", [validation: :foreign]}]
    end

    test "returns an error if given an invalid nba_game_id" do
      params = %{
        "nba_game_id" => 12,
        "line" => -5.2
      }

      {:error, message} = NbaOfferedLine.Api.create_nba_offered_line(params)

      assert message == [nba_game_id: {"invalid", [validation: :foreign]}]
    end

    test "creates an nba_line when given valid params" do
      nba_game = create(:nba_game)

      params = %{
        "nba_game_id" => nba_game.id,
        "line" => -5.2
      }

      {:ok, nba_line} = NbaOfferedLine.Api.create_nba_offered_line(params)

      assert nba_line.nba_game_id == nba_game.id
    end
  end

  describe "get_events_by_sport_by_date/2" do
    @tag api: true
    test "returns an events if token is valid" do
      use_cassette "get_events_by_sport_by_date" do
        past_date = Date.from_erl!({2019, 1, 24})

        {:ok, events} = NbaOfferedLine.Api.get_events_by_sport_by_date(past_date, 1)

        assert Enum.count(events) == 8
      end
    end
  end

  describe "handle_nba_events/2" do
    test "handles being given only date assuming [] events" do
      date_today = Date.utc_today()
      summary = NbaOfferedLine.Api.handle_nba_events(date_today)

      assert summary.event_ids_added == 0
      assert summary.offered_lines_created == 0
    end

    test "handles being given valid events when games have event_ids" do
      date_today = Date.utc_today()
      create(:nba_game, home_team: "CLE", away_team: "WAS")
      create(:nba_game, home_team: "ATL", away_team: "CHI")

      event_one = build(:event, home_team: "CLE", away_team: "WAS")
      event_two = build(:event, home_team: "ATL", away_team: "CHI")

      summary = NbaOfferedLine.Api.handle_nba_events(date_today, [event_one, event_two])

      assert summary.event_ids_added == 0
      assert summary.offered_lines_created == 2
    end

    test "handles being given valid events when games don't have event_ids" do
      date_today = Date.utc_today()

      create(:nba_game, home_team: "CLE", away_team: "WAS", event_id: nil)
      create(:nba_game, home_team: "ATL", away_team: "CHI", event_id: nil)

      event_one = build(:event, home_team: "CLE", away_team: "WAS")
      event_two = build(:event, home_team: "ATL", away_team: "CHI")

      summary = NbaOfferedLine.Api.handle_nba_events(date_today, [event_one, event_two])

      assert summary.event_ids_added == 2
      assert summary.offered_lines_created == 2
    end
  end
end