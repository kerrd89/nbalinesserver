defmodule NbaOfferedLine.Api do
  alias NbaLinesServer.Repo
  alias NbaLinesServer.NbaOfferedLine

  import Ecto.Query, only: [from: 2]

  @api_token Application.get_env(:nba_lines_server, :rundown_api_token, nil)

  @doc "helper method to create a nba_offered_line"
  @spec create_nba_offered_line(params :: map()) :: {:ok, NbaOfferedLine} | {:error, list()}
  def create_nba_offered_line(params) do
    # NOTE: validate user has not already bet on this game before
    # changeset not validating key constraint until insert, cannot case changeset
    if not NbaGame.Api.is_game_id_valid?(params["nba_game_id"]) do
      {:error, [nba_game_id: {"invalid", [validation: :foreign]}]}
    else
      nba_offered_line_changeset = NbaOfferedLine.create_offered_line_changeset(%NbaOfferedLine{}, %{
        nba_game_id: params["nba_game_id"],
        line: params["line"]
      })
  
      if nba_offered_line_changeset.valid? do
        Repo.insert(nba_offered_line_changeset)
      else
        {:error, nba_offered_line_changeset.errors}
      end
    end
  end

  @doc "helper method to get events by sport by date from rundown api"
  @spec get_events_by_sport_by_date(date :: Date, sport :: integer) :: {:ok, list(map())} | {:error, String.t()}
  def get_events_by_sport_by_date(date, sport) when not is_nil(@api_token) do
    {year, month, day} = Date.to_erl(date)
    long_month = if month < 10, do: "0#{month}", else: "#{month}"
    long_day = if day < 10, do: "0#{day}", else: "#{day}"

    url = "https://therundown-therundown-v1.p.rapidapi.com/sports/4/events/#{year}-#{month}-#{day}"

    case HTTPoison.get url, ["X-RapidAPI-Key": @api_token] do
      {:ok, %{status_code: 200, body: body}} ->
        events = Poison.decode!(body) |> Map.get("events", [])

        Enum.each(events, fn(event) ->
          IO.inspect Map.get(event, "event_id", nil)
          IO.inspect Map.get(event, "teams_normalized", nil)
        end)

        {:ok, events}
      {:ok, %{status_code: 404}} ->
        # do something with a 404
        {:error, "404"}
      {:error, %{reason: reason}} ->
        # do something with an error
        {:error, reason}
    end
  end
end