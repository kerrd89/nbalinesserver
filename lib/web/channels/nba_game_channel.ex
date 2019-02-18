defmodule NbaLinesServer.NbaGameChannel do
    @moduledoc """
    Channel to communicate to web clients with regards to alerts.
    """
  
    use NbaLinesServer.Web, :channel
    require Logger
  
    @doc "Join the nba_games channel"
    def join("nba_games", %{"guardian_token" => token}, socket) do
        with {:ok, _} <- verify_token(token) do
            today = Date.utc_today()
            one_week_ago = Date.add(today, -7)
            one_week_from_now = Date.add(today, 7)

            nba_games =  NbaGame.Api.get_nba_games_by_range(one_week_ago, one_week_from_now)

            {:ok, %{nba_games: nba_games}, socket}
        else
            {:error, reason} = resp ->
                Logger.info("#{inspect reason}")
                resp
        end
    end
  
    @doc "Handle an unauthenticated request"
    def join(_room, _params, _socket) do
        {:error, :authentication_required}
    end
end