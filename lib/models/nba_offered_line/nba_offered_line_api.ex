defmodule NbaOfferedLine.Api do
  alias NbaLinesServer.Repo
  alias NbaLinesServer.NbaOfferedLine

  import Ecto.Query, only: [from: 2]

  @doc "helper method to create a nba_offered_line"
  @spec create_nba_offered_line(params :: map()) :: {:ok, NbaOfferedLine} | {:error, list()}
  def create_nba_offered_line(params) do
    # NOTE: validate user has not already bet on this game before
    # changeset not validating key constraint until insert, cannot case changeset
    if not NbaGame.Api.is_game_id_valid?(params["nba_game_id"]) do
      {:error, [nba_game_id: {"invalid", [validation: :foreign]}]}
    else
      nba_offered_line_changeset = NbaOfferedLine.create_offered_line_changeset(%NbaOfferedLine{}, %{
        nba_game_id: params["nba_game_id"],
        line: params["line"]
      })
  
      if nba_offered_line_changeset.valid? do
        Repo.insert(nba_offered_line_changeset)
      else
        {:error, nba_offered_line_changeset.errors}
      end
    end
  end
end