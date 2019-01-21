defmodule NbaLine.Api do
  alias NbaLinesServer.Repo
  alias NbaLinesServer.NbaLine

  @doc "helper method to get all nba lines"
  @spec get_nba_lines() :: list()
  def get_nba_lines(), do: Repo.all(NbaLine)

  @doc "helper method to create a nba_line"
  @spec create_nba_line(params :: map()) :: {:ok, NbaLine} | {:error, list()}
  def create_nba_line(params) do
    # changeset not validating key constraint until insert, cannot case changeset
    if not NbaGame.Api.is_game_id_valid?(params["nba_game_id"]) do
      {:error, [nba_game_id: {"invalid", [validation: :foreign]}]}
    else
      nba_line_changeset = NbaLine.create_bet_changeset(%NbaLine{}, %{
        nba_game_id: params["nba_game_id"],
        line: params["line"],
        bet: params["bet"],
        user_id: params["user_id"]
      })
  
      if nba_line_changeset.valid? do
        Repo.insert(nba_line_changeset)
      else
        {:error, nba_line_changeset.errors}
      end
    end
  end
end