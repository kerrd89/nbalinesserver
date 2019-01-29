defmodule NbaLinesServer.SyncHelper do
    @doc """
    helper method for syncing the nba games
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

    @doc """
    helper method for syncing the nba lines
    an nba_offered_line represents a point in time, a single NBA games should have
    many nba_offered_lines, since this will be running on a cron job for games for today,
    and for games in the future.
    """
    @spec sync_nba_offered_lines() :: {:ok, map()} | {:error, String.t()}
    def sync_nba_offered_lines() do
        Logger.info("syncing nba offered lines")
        # date_today = Date.utc_today()

        # get nba lines for today from remote api
        # create records
        # broadcast update to nba_game with nba_offered_lines
    end
end