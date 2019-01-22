defmodule NbaLinesServer.NbaGameChannel do
    @moduledoc """
    Channel to communicate to web clients with regards to alerts.
    """
  
    use NbaLinesServer.Web, :channel
  
    @doc "Join the nba_games channel"
    def join("nba_lines", %{"guardian_token" => _token}, socket) do
        # TODO: get the current user off the socket
        nba_games = Date.utc_today()
        |> NbaGame.Api.get_nba_games_by_date()

        {:ok, %{nba_games: nba_games}, socket}
    end
  
    @doc "Handle an unauthenticated request"
    def join(_room, _params, _socket) do
        {:error, :authentication_required}
    end
end