defmodule Cart.Repo.Migrations.CreateNbaLines do
    use Ecto.Migration
  
    def change do
      create table(:nba_lines) do
        add :date, :date
        add :user_id, :integer
        add :home_team, :string
        add :home_team_score, :integer
        add :away_team, :string
        add :away_team_score, :integer
        add :line, :integer
        add :bet, :boolean
        add :result, :integer
  
        timestamps()
      end
    end
  end