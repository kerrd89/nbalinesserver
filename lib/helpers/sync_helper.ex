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

        # get nba_offered_lines from remote api
        # if for a particular day, the updated_at key on the remote is more
        # recent than the most current existing nba_offered_line
        # do nothing
        # otherwise, create an nba_offered_line record with 2nd offered spread.point_spread_home

        # this is the pinacle line, which is a large average for now
        # th 
        # TODO: add logic to parse through nba_lines from different affiliates and adding an avg_line field
        # broadcast update to nba_game with nba_offered_lines

        # get event_ids for games for today
        # if event_id doesn't exist, call rundown api to get event_id
        # add event_ids to games by matching long names to short names
        # TODO: make helper method to match long names to short names
        # if event_id does exist, avoid call to get event_id

        # TODO: event_id migration to nba_game for reference
        # when creating games by day, we should get the event_ids already
        # getting games by day should also include getting events by sport by day endpoint
        # limited to 100 api calls a day, pre-populating event_ids
        # would help avoid that extra daily call to get event_ids

        # start over
        # remove line from nba_line
        # replace logic referencing it with nba_line.offered_line.line, which is a float
        # reseed the database after updating the event_id to 
    end
end