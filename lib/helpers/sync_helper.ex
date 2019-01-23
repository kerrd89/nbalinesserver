defmodule NbaLinesServer.SyncHelper do
    @doc """
    helper method for syncing the nba games
    evaluate the last sync date, sync all dates back to that date

    """
    @spec sync_nba_games() :: {:ok, map()} | {:error, String.t}
    def sync_nba_games() do
        # ideally would have 2 arrays:
        # get_last_sync_day
        # process results, up to today
        # create games for today
        date_today = Date.utc_today()

        {:ok, games_created} = NbaGame.Api.handle_create_nba_games_by_date(date_today)

        dates_to_be_processed = NbaGame.Api.get_uncompleted_nba_game_dates()

        games_processed = Enum.reduce(dates_to_be_processed, 0, fn(date, acc) ->
            case NbaGame.Api.process_nba_games_by_date(date) do
                {:ok, count} -> acc + count
                {:error, _error} -> acc
            end
        end)
        {:ok, %{games_created: games_created, games_processed: 0}}
    end
end