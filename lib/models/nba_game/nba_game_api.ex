defmodule NbaGame.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.NbaGame

    require Logger

    import Ecto.Query, only: [from: 2]
  
    @doc "helper method to get all nba games for a certain date"
    @spec get_nba_games_by_date(date :: Date) :: list()
    def get_nba_games_by_date(date) do
        nba_game_query = from nba_game in NbaGame,
                         where: nba_game.date == ^date,
                         preload: [:nba_offered_lines]
 
        Repo.all(nba_game_query)
    end

    @doc "heloper method to get nba_games within a given date range"
    @spec get_nba_games_by_range(start_date :: Date, end_date :: Date) :: list()
    def get_nba_games_by_range(start_date, end_date) do
        nba_game_query = from nba_game in NbaGame,
        where: nba_game.date >= ^start_date and
        nba_game.date <= ^end_date,
        preload: [:nba_offered_lines]

        Repo.all(nba_game_query)
    end

    @doc "helper method to get date records for nba_games which have not been completed"
    @spec get_uncompleted_nba_game_dates() :: list(Date)
    def get_uncompleted_nba_game_dates() do
        today = Date.utc_today()

        nba_game_date_query = from nba_game in NbaGame,
                         where: nba_game.completed == false and
                                nba_game.date < ^today,
                         distinct: true,
                         order_by: nba_game.date,
                         select: nba_game.date
        Repo.all(nba_game_date_query)       
    end

    @doc "helper method to get nba_games which have not been completed for a certain date"
    @spec get_uncompleted_nba_games_by_date(date :: Date) :: list(NbaGame)
    def get_uncompleted_nba_games_by_date(date) do
        nba_game_date_query = from nba_game in NbaGame,
                         where: nba_game.completed == false and
                         nba_game.date == ^date
        Repo.all(nba_game_date_query)       
    end

    @doc "helper method to get all nba games for a certain date"
    @spec get_nba_game_by_id(nba_game_id :: integer) :: NbaGame | nil
    def get_nba_game_by_id(nba_game_id), do: Repo.get(NbaGame, nba_game_id)
  
    @doc "helper method to create an nba game"
    @spec create_nba_game(params :: map()) :: {:ok, NbaLine} | {:error, list()}
    def create_nba_game(params) do
      nba_game_changeset = NbaGame.create_game_changeset(%NbaGame{}, %{
        date: params["date"],
        home_team: params["home_team"],
        away_team: params["away_team"],
        start_time: params["start_time"]
      })
  
      if nba_game_changeset.valid? do
        Repo.insert(nba_game_changeset)
      else
        {:error, nba_game_changeset.errors}
      end
    end

    @doc "helper method to complete an nba game"
    @spec update_nba_game(params :: map()) :: {:ok, NbaLine} | {:error, list()}
    def update_nba_game(params) do
        nba_game_id = Map.get(params, "nba_game_id", nil)
        is_finished? = Map.get(params, "is_finished?", nil)

        case {is_finished?, nba_game_id} do
            {_, nil} -> {:error, "nba_game_id invalid"}
            {true, nba_game_id} ->
                # complete
                case Repo.get(NbaGame, nba_game_id) do
                    %NbaGame{} = game ->
                        nba_game_changeset = NbaGame.complete_game_changeset(game, %{
                            home_team_score: params["home_team_score"],
                            away_team_score: params["away_team_score"],
                            clock: params["clock"],
                            period: params["period"],
                            completed: true,
                            bet_count: 0
                        })
                        if nba_game_changeset.valid? do
                            {:ok, nba_game} = response = Repo.update(nba_game_changeset)
                            NbaLine.Api.process_bets(nba_game)
                            response
                        else
                            {:error, nba_game_changeset.errors}
                        end
                    _ -> {:error, "nba_game_id invalid"}
                end
            {_, nba_game_id} ->
                # update
                case Repo.get(NbaGame, nba_game_id) do
                    %NbaGame{} = game ->
                        nba_game_changeset = NbaGame.update_game_changeset(game, %{
                            home_team_score: params["home_team_score"],
                            away_team_score: params["away_team_score"],
                            clock: params["clock"],
                            period: params["period"]
                        })
                        if nba_game_changeset.valid? do
                            Repo.update(nba_game_changeset)
                        else
                            {:error, nba_game_changeset.errors}
                        end
                    _ -> {:error, "nba_game_id invalid"}
                end
        end
    end

    @doc """
    helper method to check if an nba_game_id is valid
    checks if game exists
    todo: check if game has not completed
    """
    @spec is_game_id_valid?(nba_game_id :: integer) :: boolean
    def is_game_id_valid?(nba_game_id) when is_integer(nba_game_id) do
        not is_nil(Repo.get(NbaGame, nba_game_id))
    end
    def is_game_id_valid?(_), do: false

    @doc """
    helper method to generate new nba_games from api json response from data.nba.net
    """
    @spec handle_create_nba_games_by_date(date :: Date) :: {:ok, integer()} | {:error, Sring.t()}
    def handle_create_nba_games_by_date(date) do
        nba_games_for_today = get_nba_games_by_date(date)

        # if there are already games today, do nothing
        if Enum.count(nba_games_for_today) > 0 do
            {:ok, 0}
        else
            {year, month, day} = Date.to_erl(date)
            long_month = if month < 10, do: "0#{month}", else: "#{month}"
            long_day = if day < 10, do: "0#{day}", else: "#{day}"

            url = "http://data.nba.net/10s/prod/v1/#{year}#{long_month}#{long_day}/scoreboard.json"

            case HTTPoison.get(url) do
                {:ok, %{status_code: 200, body: body}} ->
                    nba_games = Poison.decode!(body) |> Map.get("games", [])

                    games_created = Enum.reduce(nba_games, 0, fn(nba_game, acc) ->
                        home_team = Map.get(nba_game, "hTeam", %{}) |> Map.get("triCode", nil)
                        away_team = Map.get(nba_game, "vTeam", %{}) |> Map.get("triCode", nil)
                        start_time = Map.get(nba_game, "startTimeUTC", nil) |> NaiveDateTime.from_iso8601!()

                        params = %{
                            "date" => date,
                            "home_team" => home_team,
                            "away_team" => away_team,
                            "start_time" => start_time
                        }

                        case create_nba_game(params) do
                            {:ok, %NbaGame{}} ->
                                acc + 1
                            {:error, _error} ->
                                acc
                        end
                    end)

                    {:ok, games_created}
                {:ok, %{status_code: 404}} ->
                    # do something with a 404
                    {:error, "404"}
                {:error, %{reason: reason}} ->
                    # do something with an error
                    {:error, reason}
            end
        end
    end

    @doc """
    helper method to update new nba_games from api json response from data.nba.net
    """
    @spec handle_update_nba_games_by_date(date :: Date) :: {:ok, integer()} | {:error, Sring.t()}
    def handle_update_nba_games_by_date(date) do
        uncompleted_nba_games = get_uncompleted_nba_games_by_date(date)

        # if there are no uncompleted nba_games, do nothing
        if Enum.count(uncompleted_nba_games) <= 0 do
            {:ok, 0}
        else
            {year, month, day} = Date.to_erl(date)
            long_month = if month < 10, do: "0#{month}", else: "#{month}"
            long_day = if day < 10, do: "0#{day}", else: "#{day}"

            url = "http://data.nba.net/10s/prod/v1/#{year}#{long_month}#{long_day}/scoreboard.json"

            case HTTPoison.get(url) do
                {:ok, %{status_code: 200, body: body}} ->
                    nba_games = Poison.decode!(body) |> Map.get("games", [])

                    games_updated = Enum.reduce(nba_games, 0, fn(nba_game, acc) ->
                        home_team = Map.get(nba_game, "hTeam", %{}) |> Map.get("triCode", nil)
                        away_team = Map.get(nba_game, "vTeam", %{}) |> Map.get("triCode", nil)
                        home_team_score = Map.get(nba_game, "hTeam", %{}) |> Map.get("score", nil)
                        away_team_score = Map.get(nba_game, "vTeam", %{}) |> Map.get("score", nil)
                        period = Map.get(nba_game, "period", %{}) |> Map.get("current", nil)
                        clock = Map.get(nba_game, "clock", nil)
                        status_num = Map.get(nba_game, "statusNum", 1)

                        if home_team_score == "" and away_team_score == "" do
                            Logger.warn("game not worth updating, no scores #{inspect home_team} #{inspect away_team}")

                            acc
                        else
                            {home_team_score_int, _} = Integer.parse(home_team_score)
                            {away_team_score_int, _} = Integer.parse(away_team_score)

                            # assumption at this date is that games are only for this day, only check for teams
                            uncompleted_game = uncompleted_nba_games |> Enum.find(fn(search) ->
                                search.home_team == home_team and search.away_team == away_team
                            end)

                            # if the game exists
                            if not is_nil(uncompleted_game) do
                                complete_params = %{
                                    "nba_game_id" => uncompleted_game.id,
                                    "home_team_score" => home_team_score_int,
                                    "away_team_score" => away_team_score_int,
                                    "period" => period,
                                    "clock" => clock,
                                    "is_finished?" => status_num == 3
                                }
    
                                case update_nba_game(complete_params) do
                                    {:ok, %NbaGame{}} -> acc + 1
                                    {:error, error} ->
                                        Logger.error("#{inspect error}")
                                        acc
                                end
                            else
                                Logger.warn("game not updated #{inspect nba_game}")
                                acc
                            end
                        end
                    end)

                    {:ok, games_updated}
                {:ok, %{status_code: 404}} ->
                    # do something with a 404
                    {:error, "404"}
                {:error, %{reason: reason}} ->
                    # do something with an error
                    {:error, reason}
            end
        end
    end

    @doc "helper method to retrieve games by date, home team, away team"
    @spec get_game_by_teams_and_date(date :: Date, home_team :: String.t(), away_team :: String.t()) :: NbaGame | nil
    def get_game_by_teams_and_date(date, home_team, away_team) do
        query = from nba_game in NbaGame,
                    where: nba_game.date == ^date and
                    nba_game.home_team == ^home_team and
                    nba_game.away_team == ^away_team

        Repo.one(query)
    end

    @doc "helper method to update nba_games to include an event_id, if it doesn't already exist"
    @spec add_event_id(nba_game :: NbaGame, event_id :: String.t()) :: {:ok, NbaGame} | {:error, String.t()}
    def add_event_id(nba_game, event_id) do
        nba_game_changeset = NbaGame.event_id_changeset(nba_game, %{event_id: event_id})

        if nba_game_changeset.valid? do
            Repo.update(nba_game_changeset)
        else
            {:error, "error updating"}
        end
    end
end