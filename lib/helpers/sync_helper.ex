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
        games_updated = NbaGame.Api.get_uncompleted_nba_game_dates()
            |> Enum.reduce(0, fn(date, acc) ->
                case NbaGame.Api.handle_update_nba_games_by_date(date) do
                    {:ok, count} -> acc + count
                    {:error, _error} -> acc
                end
            end)

        Logger.info("synced nba games: games_created - #{games_created} games_updated - #{games_updated}")

        # broadcast update to nba_games, preloaded with offered lines order_by inserted_at

        {:ok, %{games_created: games_created, games_updated: games_updated}}
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
        date_today = Date.utc_today()

        # get nba_offered_lines from remote api
        {:ok, events} = NbaOfferedLine.Api.get_events_by_sport_by_date(date_today)

        summary = NbaOfferedLine.Api.handle_nba_events(date_today, events)

        Logger.info("synced offered lines: event_ids_added - #{summary.event_ids_added}, offered_lined_created - #{summary.offered_lines_created}")

        # future opportunity to get all lines, track when updated, and provide realtime data
        # currently, since we are taking the avg, it can constantly change, we create each time

        # broadcast update to nba_games, preloaded with offered lines order_by inserted_at

        # when creating games by day, we should get the event_ids already
        # getting games by day should also include getting events by sport by day endpoint
        # limited to 100 api calls a day, pre-populating event_ids
    end
end