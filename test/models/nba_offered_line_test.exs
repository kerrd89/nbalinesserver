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
    test "returns an events if token is valid" do
      use_cassette "get_events_by_sport_by_date" do
        past_date = Date.from_erl!({2019, 1, 24})

        {:ok, events} = NbaOfferedLine.Api.get_events_by_sport_by_date(past_date, 1)

        assert Enum.count(events) == 8
      end
    end
  end
end