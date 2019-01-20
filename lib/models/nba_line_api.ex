defmodule NbaLine.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.NbaLine
  
    @doc "helper method to get all nba lines"
    @spec get_nba_lines() :: list()
    def get_nba_lines(), do: Repo.all(NbaLine)
  
    @doc "helper method to create a nba_line"
    @spec create_nba_line(params :: map()) :: {:ok, NbaLine} | {:error, list()}
    def create_nba_line(params) do
      nba_line_changeset = NbaLine.create_bet_changeset(%NbaLine{}, %{
        date: params["date"],
        home_team: params["home_team"],
        away_team: params["away_team"],
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