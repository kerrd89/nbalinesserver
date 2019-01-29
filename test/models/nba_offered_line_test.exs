defmodule NbaOfferedLineTest do
  use NbaLinesServer.RepoCase

  import NbaLinesServer.Factory

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
end