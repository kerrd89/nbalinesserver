defmodule NbaLinesServer.Repo.Migrations.AddTimeAndScheduledTime do
    use Ecto.Migration
  
    def change do
      alter table(:nba_games) do
        add :event_id, :string
      end
    end
  end