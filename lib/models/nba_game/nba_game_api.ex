defmodule NbaGame.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.NbaGame

    import Ecto.Query, only: [from: 2]
  
    @doc "helper method to get all nba games for a certain date"
    @spec get_nba_games_by_date(date :: Date) :: list()
    def get_nba_games_by_date(date) do
        nba_game_query = from nba_game in NbaGame,
                         where: nba_game.date == ^date
 
        Repo.all(nba_game_query)
    end

    @doc "helper method to get date records for nba_games which have not been completed"
    @spec get_uncompleted_nba_game_dates() :: list(Date)
    def get_uncompleted_nba_game_dates() do
        nba_game_date_query = from nba_game in NbaGame,
                         where: is_nil(nba_game.home_team_score) and
                         is_nil(nba_game.away_team_score),
                         distinct: true,
                         order_by: nba_game.date,
                         select: nba_game.date
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
        away_team: params["away_team"]
      })
  
      if nba_game_changeset.valid? do
        Repo.insert(nba_game_changeset)
      else
        {:error, nba_game_changeset.errors}
      end
    end

    @doc "helper method to complete an nba game"
    @spec complete_nba_game(params :: map()) :: {:ok, NbaLine} | {:error, list()}
    def complete_nba_game(params) do
        nba_game_id = Map.get(params, "nba_game_id", nil)

        if is_nil(nba_game_id) do
            {:error, "nba_game_id invalid"}
        else
            case Repo.get(NbaGame, nba_game_id) do
                %NbaGame{} = game ->
                    nba_game_changeset = NbaGame.complete_game_changeset(game, %{
                        home_team_score: params["home_team_score"],
                        away_team_score: params["away_team_score"],
                        completed: true
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
                        
                        params = %{
                            "date" => date,
                            "home_team" => home_team,
                            "away_team" => away_team
                        }

                        case create_nba_game(params) do
                            {:ok, %NbaGame{}} -> acc + 1
                            {:error, _error} -> acc
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

    @doc "helper method to complete uncompleted games for a given date"
    @spec process_nba_games_by_date(date :: Date) :: {:ok, integer()} | {:error, String.t()}
    def process_nba_games_by_date(_date) do
        {:ok, 0}
    end
end