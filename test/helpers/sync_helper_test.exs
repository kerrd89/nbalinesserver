defmodule NbaLinesServer.SyncHelperTest do
    use NbaLinesServer.RepoCase
  
    alias NbaLinesServer.SyncHelper
  
    describe "sync_nba_games/0" do
        test "creates nba_games for today" do
            {:ok, %{games_created: games_created}} = SyncHelper.sync_nba_games()
            nba_games = Date.utc_today() |> NbaGame.Api.get_nba_games_by_date()

            assert games_created == Enum.count(nba_games)
        end
    end
end