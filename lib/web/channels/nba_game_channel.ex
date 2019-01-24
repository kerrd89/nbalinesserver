defmodule NbaLinesServer.NbaGameChannel do
    @moduledoc """
    Channel to communicate to web clients with regards to alerts.
    """
  
    use NbaLinesServer.Web, :channel
  
    @doc "Join the nba_games channel"
    def join("nba_games", %{"guardian_token" => token}, socket) do
        with {:ok, user_id} <- verify_token(token) do
            nba_games = Date.utc_today()
            |> NbaGame.Api.get_nba_games_by_date()

            {:ok, %{nba_games: nba_games}, socket}
        else
            {:error, _} = resp -> resp
        end
    end
  
    @doc "Handle an unauthenticated request"
    def join(_room, _params, _socket) do
        {:error, :authentication_required}
    end

    @salt "4Q1cajEv"
    @max_age 86400

    def verify_token(token) do
        NbaLinesServer.Endpoint
        |> Phoenix.Token.verify(@salt, token, max_age: @max_age)
    end
end