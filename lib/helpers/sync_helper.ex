defmodule NbaLinesServer.SyncHelper do
    @doc """
    helper method for syncing the nba games
    evaluate the last sync date, sync all dates back to that date
    """
    require Logger
    @spec sync_nba_games() :: {:ok, map()} | {:error, String.t}
    def sync_nba_games() do
        Logger.info("syncing nba games")
        date_today = Date.utc_today()

        # create games for today, method does nothing if already created
        {:ok, games_created} = NbaGame.Api.handle_create_nba_games_by_date(date_today)

        # get dates for past uncompleted games, complete them
        games_completed = NbaGame.Api.get_uncompleted_nba_game_dates()
            |> Enum.reduce(0, fn(date, acc) ->
                case NbaGame.Api.handle_update_nba_games_by_date(date) do
                    {:ok, count} -> acc + count
                    {:error, _error} -> acc
                end
            end)

        Logger.info("synced nba games: games_created - #{games_created} games_updated - #{games_completed}")

        {:ok, %{games_created: games_created, games_completed: games_completed}}
    end
end