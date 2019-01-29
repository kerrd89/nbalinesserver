defmodule Cart.Repo.Migrations.CreateNbaOfferedLines do
  use Ecto.Migration

  def change do
    create table(:nba_offered_lines) do
      add :line, :float
      add :nba_game_id, references(:nba_games, on_delete: :nothing)

      timestamps()
    end

    alter table(:nba_lines) do
      add :nba_offered_line_id, references(:nba_offered_lines, on_delete: :nothing)
    end
  end
end