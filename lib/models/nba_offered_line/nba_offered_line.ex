defmodule NbaLinesServer.NbaOfferedLine do
  use NbaLinesServer.Web, :model
  
  @create_offered_line_required_fields [:line, :nba_game_id]
    
  schema "nba_offered_lines" do
      belongs_to :nba_game, NbaLinesServer.NbaGame
      field :line, :float

      timestamps()
    end
  
  @doc "changeset to create a nba line record"
  def create_offered_line_changeset(model, params \\ :empty) do
    model
    |> cast(params, @create_offered_line_required_fields)
    |> foreign_key_constraint(:nba_game_id)
    |> foreign_key_constraint(:nba_line_id)
    |> validate_required(@create_offered_line_required_fields)
  end
end