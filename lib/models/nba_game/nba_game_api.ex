defmodule NbaGame.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.NbaGame
  
    @doc "helper method to get all nba games for a certain date"
    @spec get_nba_games_by_date(date :: Date) :: list()
    def get_nba_games_by_date(_date), do: Repo.all(NbaGame)
  
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
                        away_team_score: params["away_team_score"]
                        })
                        
                    if nba_game_changeset.valid? do
                        {:ok, nba_game} = Repo.update(nba_game_changeset)

                        NbaLines.Api.process_bets(nba_game)
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
end