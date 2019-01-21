defmodule NbaLinesServer.RepoCase do
    use ExUnit.CaseTemplate
  
    using do
      quote do
        alias NbaLinesServer.Repo
  
        import Ecto
        import Ecto.Query
        import NbaLinesServer.RepoCase

        def create_default_nba_game() do
          NbaGame.Api.create_nba_game(%{
            "date" => Date.utc_today(),
            "home_team" => "cavs",
            "away_team" => "bulls"
          })
        end
      end
    end
  
    setup tags do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(NbaLinesServer.Repo)
  
      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(NbaLinesServer.Repo, {:shared, self()})
      end
  
      :ok
    end
  end