defmodule NbaLinesServer.NbaGame do
    use NbaLinesServer.Web, :model
  
    @optional_fields [:bet_count, :start_time, :clock, :period]
    @create_game_required_fields [:date, :home_team, :away_team, :start_time]
    @complete_game_required_fields [:home_team_score, :away_team_score, :completed]
    @update_game_required_fields [:home_team_score, :away_team_score]
  
    @derive {Poison.Encoder, only: [
        :id, :date, :home_team, :home_team_score, :away_team, :away_team_score,
        :completed, :bet_count, :updated_at, :start_time, :period, :clock,
        :nba_offered_lines
    ]}

    schema "nba_games" do
        field :date, :date
        field :home_team, :string
        field :home_team_score, :integer
        field :away_team, :string
        field :away_team_score, :integer
        field :completed, :boolean, default: false
        field :bet_count, :integer
        field :start_time, :naive_datetime
        field :period, :integer
        field :clock, :string

        # representing how many bets were placed
        has_many :nba_lines, NbaLinesServer.NbaLine
        # representing how many offered lines were registered
        has_many :nba_offered_lines, NbaLinesServer.NbaOfferedLine

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
        |> cast(params, @complete_game_required_fields ++ @optional_fields)
        |> validate_required(@complete_game_required_fields)
    end

    @doc "changeset to update the progress of an nba game"
    def update_game_changeset(model, params \\ :empty) do
        model
        |> cast(params, @update_game_required_fields ++ @optional_fields)
        |> validate_required(@update_game_required_fields)
    end
end