defmodule NbaOfferedLine.Api do
  alias NbaLinesServer.Repo
  alias NbaLinesServer.NbaOfferedLine

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
  def get_events_by_sport_by_date(date, sport \\ 4) do
    {year, month, day} = Date.to_erl(date)
    long_month = if month < 10, do: "0#{month}", else: "#{month}"
    long_day = if day < 10, do: "0#{day}", else: "#{day}"

    url = "https://therundown-therundown-v1.p.rapidapi.com/sports/#{sport}/events/#{year}-#{long_month}-#{long_day}"

    case HTTPoison.get url, ["X-RapidAPI-Key": @api_token] do
      {:ok, %{status_code: 200, body: body}} ->
        events = Poison.decode!(body) |> Map.get("events", [])

        trim_events = Enum.map(events, fn(event) ->
          lines = Map.get(event, "lines", %{})
          lines_total = Enum.reduce(lines, 0, fn({_affiliate_id, line}, acc) ->
            point_spread = Map.get(line, "spread", %{}) |> Map.get("point_spread_home")

            acc + point_spread
          end)
          event_id = Map.get(event, "event_id", nil)
          home_team = Map.get(event, "teams_normalized", nil)
            |> Enum.find(fn(team) -> Map.get(team, "is_home", false) end)
          away_team = Map.get(event, "teams_normalized", nil)
            |> Enum.find(fn(team) -> Map.get(team, "is_away", false) end)
          avg_line = lines_total/Enum.count(lines)
          # TODO: make struct for this
          %{
            event_id: event_id,
            home_team: home_team,
            away_team: away_team,
            avg_line: avg_line
          }
        end)

        {:ok, trim_events}
      {:ok, %{status_code: 404}} ->
        # do something with a 404
        {:error, "404"}
      {:error, %{reason: reason}} ->
        # do something with an error
        {:error, reason}
    end
  end

  @doc """
  helper method to handle events from the rundown api
  adds event_ids to nba_games and creates offered lines from events
  """
  @spec handle_nba_events(date :: Date, events :: map()) :: {:ok, map()} | {:error, String.t()}
  def handle_nba_events(date, events \\ []) do
    Enum.reduce(events, %{event_ids_added: 0, offered_lines_created: 0}, fn(event, acc) ->
      # match out values to be used from acc
      %{event_ids_added: event_ids_added, offered_lines_created: offered_lines_created} = acc
      # get nba_game relevant to this event
      nba_game = NbaGame.Api.get_game_by_teams_and_date(date, event.home_team, event.away_team)

      # if there is no event_id on the nba_game, add it and increment the accumulator
      event_ids_added = if is_nil(nba_game.event_id) do
        NbaGame.Api.add_event_id(nba_game, event.event_id)
        event_ids_added + 1
      else
        event_ids_added
      end

      params = %{
          "nba_game_id" => nba_game.id,
          "line" => event.avg_line
      }

      {:ok, _nba_offered_line} = create_nba_offered_line(params)

      %{
        event_ids_added: event_ids_added,
        offered_lines_created: offered_lines_created + 1
      }
    end)
  end
end