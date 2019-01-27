defmodule NbaLinesServer.Repo.Migrations.AddTimeAndScheduledTime do
    use Ecto.Migration
  
    def change do
      alter table(:nba_games) do
        add :start_time, :naive_datetime
        add :period, :integer
        add :clock, :string
      end
    end
  end