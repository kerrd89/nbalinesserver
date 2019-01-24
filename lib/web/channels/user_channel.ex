defmodule NbaLinesServer.UserChannel do
    @moduledoc """
    Channel to communicate to web clients with regards to alerts.
    """
  
    use NbaLinesServer.Web, :channel
    require Logger
  
    @doc "Join the nba_lines channel"
    def join("user:" <> user_id, %{"guardian_token" => token}, socket) do
        with {:ok, _} <- verify_token(token) do
            Logger.info("user_id:#{user_id} joined user channel")

            # get the nba_lines for a given user
            nba_lines = NbaLine.Api.get_nba_lines_by_user_id(user_id)

            {:ok, %{nba_lines: nba_lines}, assign(socket, :user_id, user_id)}
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
  
    # @doc "Handle marking an alert as awknowledged"
    # def handle_in("create_line", params, socket) do
    #     case NbaLine.Api.create_nba_line(params) do
    #         {:ok, %NbaLinesServer.NbaLine{}} ->
    #             nba_lines = NbaLine.Api.get_nba_lines_by_user_id(params["user_id"])

    #             {:reply, {:ok, %{nba_lines: nba_lines}}, socket}
    #         {:error, error} -> {:reply, {:error, %{"error" => error}}, socket}
    #     end
    
    #     {:reply, :ok, socket}
    # end
end