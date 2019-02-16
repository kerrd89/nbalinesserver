defmodule Canvaserver.Repo.Migrations.RemoveMapsMapUrl do
  use Ecto.Migration

  def change do
    alter table(:nba_lines) do
      remove :line
    end
  end
end