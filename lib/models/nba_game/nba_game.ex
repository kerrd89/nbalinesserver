defmodule NbaLinesServer.NbaGame do
    use NbaLinesServer.Web, :model
  
    @create_game_required_fields [:date, :home_team, :away_team]
    @complete_game_required_fields [:home_team_score, :away_team_score, :completed]
  
    schema "nba_games" do
        field :date, :date
        field :home_team, :string
        field :home_team_score, :integer
        field :away_team, :string
        field :away_team_score, :integer
        field :completed, :boolean, default: false
        field :bet_count, :integer

        has_many :nba_lines, NbaLinesServer.NbaLine

        timestamps()
    end
  
    @doc "changeset to create a new nba game record"
    def create_game_changeset(model, params \\ :empty) do
      model
      |> cast(params, @create_game_required_fields)
      |> validate_required(@create_game_required_fields)
    end

    @doc "changeset to record the result of an nba game"
    def complete_game_changeset(model, params \\ :empty) do
        model
        |> cast(params, @complete_game_required_fields)
        |> validate_required(@complete_game_required_fields)
    end
  end