defmodule NbaLinesServer.RepoCase do
    use ExUnit.CaseTemplate
  
    using do
      quote do
        alias NbaLinesServer.Repo
  
        import Ecto
        import Ecto.Query
        import NbaLinesServer.RepoCase
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