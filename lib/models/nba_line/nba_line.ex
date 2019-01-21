defmodule NbaLinesServer.NbaLine do
  use NbaLinesServer.Web, :model
  
  @create_bet_required_fields [:line, :bet, :user_id, :nba_game_id]
  @complete_bet_required_fields [:result]
    
  schema "nba_lines" do
      belongs_to :nba_game, NbaLinesServer.NbaGame
      field :line, :integer
      field :user_id, :integer

      # boolean represents if user choose above or below line
      field :bet, :boolean

      # boolean represents evaluated bets and their results
      # null will represent unevaluated on cron jobs
      # 2 represents an incorrect :bet against the :line
      # 1 represents a correct :bet against the :line
      # 0 represents a push against the line
      field :result, :integer

      timestamps()
    end
  
    @doc "changeset to create a nba line record"
    def create_bet_changeset(model, params \\ :empty) do
      model
      |> cast(params, @create_bet_required_fields)
      |> foreign_key_constraint(:nba_game_id)
      |> validate_required(@create_bet_required_fields)
    end

    @doc "changeset to complete a nba line record"
    def complete_bet_changeset(model, params \\ :empty) do
      model
      |> cast(params, @complete_bet_required_fields)
      |> validate_required(@complete_bet_required_fields)
    end
end