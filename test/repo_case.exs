defmodule NbaLinesServer.RepoCase do
    use ExUnit.CaseTemplate
  
    using do
      quote do
        alias NbaLinesServer.Repo
  
        import Ecto
        import Ecto.Query
        import NbaLinesServer.RepoCase

        def create_default_nba_game(params \\ %{}) do
          NbaGame.Api.create_nba_game(%{
            "date" => Map.get(params, "date", Date.utc_today()),
            "home_team" => Map.get(params, "home_team", "cavs"),
            "away_team" => Map.get(params, "away_team", "bulls")
          })
        end

        def create_default_completed_nba_game() do
          {:ok, nba_game} = create_default_nba_game()

          NbaLinesServer.NbaGame.complete_game_changeset(nba_game, %{
            home_team_score: 102,
            away_team_score: 100
          }) |> Repo.update()
        end

        def create_default_user() do
          User.Api.create_user(%{
            "email" => "test@test.com",
            "first_name" => "joe",
            "last_name" => "bloe",
            "password" => "temp1234"
          })
        end

        def create_default_nba_line(nba_game_id, user_id) do
          NbaLine.Api.create_nba_line(%{
            "nba_game_id" => nba_game_id,
            "user_id" => user_id,
            "line" => -5,
            "bet" => true
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