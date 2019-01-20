defmodule NbaLinesServer.NbaLine do
    use NbaLinesServer.Web, :model
  
    @create_bet_required_fields [:date, :home_team, :away_team, :line, :bet, :user_id]
    @complete_bet_required_fields [:home_team_score, :away_team_score, :result]

    # Todo: make helper for atoms of nba teams
  
    schema "nba_lines" do
        field :date, :date
        field :user_id, :integer
        field :home_team, :string
        field :home_team_score, :integer
        field :away_team, :string
        field :away_team_score, :integer
        field :line, :integer

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
  
    @doc """
    Creates a changeset based on the `model` and `params`.
    If no params are provided, an invalid changeset is returned
    with no validation performed.
    """
    def create_bet_changeset(model, params \\ :empty) do
      model
      |> cast(params, @create_bet_required_fields)
      |> validate_required(@create_bet_required_fields)
    end
  end