defmodule NbaLinesServer.NbaLineChannel do
    @moduledoc """
    Channel to communicate to web clients with regards to alerts.
    """
  
    use NbaLinesServer.Web, :channel
  
    @doc "Join the nba_lines channel"
    def join("nba_lines", %{"guardian_token" => _token}, socket) do
        # TODO: get the current user off the socket
        nba_lines = NbaLine.Api.get_nba_lines_by_user_id(nil)
        {:ok, %{nba_lines: nba_lines}, socket}
    end
  
    @doc "Handle an unauthenticated request"
    def join(_room, _params, _socket) do
        {:error, :authentication_required}
    end
  
    @doc "Handle an unauthenticated request"
    def handle_guardian_auth_failure(reason), do: {:error, %{error: reason}}
  
    @doc "Handle marking an alert as awknowledged"
    def handle_in("create_line", params, socket) do
        case NbaLine.Api.create_nba_line(params) do
            {:ok, %NbaLinesServer.NbaLine{}} ->
                nba_lines = NbaLine.Api.get_nba_lines_by_user_id(params["user_id"])

                {:reply, {:ok, %{nba_lines: nba_lines}}, socket}
            {:error, error} -> {:reply, {:error, %{"error" => error}}, socket}
        end
    
        {:reply, :ok, socket}
    end
end