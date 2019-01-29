defmodule NbaLine.Api do
  alias NbaLinesServer.Repo
  alias NbaLinesServer.NbaLine

  import Ecto.Query, only: [from: 2]

  @doc "helper method to get all nba lines"
  @spec get_nba_lines() :: list()
  def get_nba_lines(), do: Repo.all(NbaLine)

  @doc "helper method to get all nba lines"
  @spec get_nba_lines_by_user_id(user_id :: integer()) :: list()
  def get_nba_lines_by_user_id(user_id) do
    nba_lines_query = from nba_line in NbaLine,
                      where: nba_line.user_id == ^user_id

    Repo.all(nba_lines_query)
  end
  def get_nba_lines_by_user_id(nil), do: []

  @doc "helper method to create a nba_line"
  @spec create_nba_line(params :: map()) :: {:ok, NbaLine} | {:error, list()}
  def create_nba_line(params) do
    # NOTE: validate user has not already bet on this game before
    # changeset not validating key constraint until insert, cannot case changeset
    if not NbaGame.Api.is_game_id_valid?(params["nba_game_id"]) do
      {:error, [nba_game_id: {"invalid", [validation: :foreign]}]}
    else
      nba_line_changeset = NbaLine.create_bet_changeset(%NbaLine{}, %{
        nba_game_id: params["nba_game_id"],
        line: params["line"],
        bet: params["bet"],
        user_id: params["user_id"],
        nba_offered_line_id: params["nba_offered_line_id"]
      })
  
      if nba_line_changeset.valid? do
        Repo.insert(nba_line_changeset)
      else
        {:error, nba_line_changeset.errors}
      end
    end
  end

  @doc "helper method to complete an nba_line"
  @spec complete_nba_line(nba_line :: NbaLine, params :: map()) :: {:ok, NbaLine} | {:error, String.t}
  def complete_nba_line(%NbaLine{line: line, bet: bet} = nba_line, params) do
    # final_difference always represents home_team vs. away_team
    # line always represents points to or against the home team
    # bet always represents true false statement about line
    final_diff = Map.get(params, "final_difference", nil)

    result = case {line, final_diff, bet} do
        {line, final_diff, bet} when line > 0 and final_diff < 0 ->
          # home team favored, home team lost
          cond do
            bet -> 2
            !bet -> 1
          end
        {line, final_diff, bet} when line > 0 and final_diff > 0 ->
          # home team favored, home team won
          home_team_performance_against_line = line - final_diff
          
          cond do
            home_team_performance_against_line < 0 and bet -> 1
            home_team_performance_against_line < 0 and !bet -> 2
            home_team_performance_against_line > 0 and !bet -> 1
            home_team_performance_against_line > 0 and bet -> 2
            home_team_performance_against_line == 0 -> 0
          end
        {line, final_diff, bet} when line < 0 and final_diff > 0 ->
          # hme team underdog, home team won
          cond do
            bet -> 1
            !bet -> 2
          end
        { line, final_diff, bet } when line < 0 and final_diff < 0 ->
          # home team underdog, lost
          home_team_performance_against_line = line - final_diff

          cond do
            # away team won by less than the line
            home_team_performance_against_line < 0 and bet -> 1
            home_team_performance_against_line < 0 and !bet -> 2
            home_team_performance_against_line > 0 and bet -> 1
            home_team_performance_against_line > 0 and !bet -> 2
            home_team_performance_against_line == 0 -> 0
          end
      end

    complete_bet_changeset = NbaLine.complete_bet_changeset(nba_line, %{"result" => result})

    if complete_bet_changeset.valid? do
      case Repo.update(complete_bet_changeset) do
        {:ok, complete_nba_line} -> {:ok, complete_nba_line}
        {:error, error} -> {:error, error}
      end
    else
      {:error, complete_bet_changeset.errors}
    end
  end

  @doc "helper method to return unresolved lines for a given game"
  @spec get_lines_for_game(nba_game_id :: integer()) :: list() 
  def get_lines_for_game(nba_game_id) do
    nba_line_query = from nba_line in NbaLine,
                    where: nba_line.nba_game_id == ^nba_game_id
                    and is_nil(nba_line.result)

    Repo.all(nba_line_query)
  end

  @doc "helper method to process lines for a given game"
  @spec process_bets(nba_game :: NbaLinesServer.NbaGame) :: {:ok, integer()} | {:error, String.t}
  def process_bets(%NbaLinesServer.NbaGame{id: nba_game_id,
    home_team_score: home_team_score,
    away_team_score: away_team_score})
  when not is_nil(home_team_score) and not is_nil(away_team_score) do
    final_difference = home_team_score - away_team_score

    count = get_lines_for_game(nba_game_id) |> Enum.reduce(0, fn(nba_line, acc) ->
      case complete_nba_line(nba_line, %{"final_difference" => final_difference}) do
        {:ok, _updated_nba_line} -> acc + 1
        {:error, _error} -> acc
      end
    end)

    {:ok, count}
  end
end