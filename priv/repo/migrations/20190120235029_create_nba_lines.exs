defmodule Cart.Repo.Migrations.CreateNbaLines do
    use Ecto.Migration
  
    def change do
      create table(:nba_lines) do
        add :line, :integer
        add :bet, :boolean
        add :result, :integer
        add :nba_game_id, references(:nba_games, on_delete: :nothing)
        add :user_id, references(:users, on_delete: :nothing)
  
        timestamps()
      end
    end
  end