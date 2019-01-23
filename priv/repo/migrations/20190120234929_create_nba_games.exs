defmodule Cart.Repo.Migrations.CreateNbaGames do
    use Ecto.Migration
  
    def change do
      create table(:nba_games) do
        add :date, :date
        add :home_team, :string
        add :home_team_score, :integer
        add :away_team, :string
        add :away_team_score, :integer
        add :completed, :boolean
        add :bet_count, :integer
  
        timestamps()
      end
    end
  end