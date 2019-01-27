defmodule NbaLinesServer.UserSocket do
    @moduledoc """
    Sets up the web socket connections for the web server, as well
    as defines the channels that are available.
    * NbaGameChannel - provides nba_games
    * NbaLineChannel - create bets or view bets
    * UserChannel - 
    """
  
    use Phoenix.Socket
    require Logger
  
    ## Channels
    channel "nba_games", NbaLinesServer.NbaGameChannel
    channel "user:*", NbaLinesServer.UserChannel
  
    ## Transports
    transport :websocket, Phoenix.Transports.WebSocket

    def connect(%{"guardian_token" => token}, socket) do
      case NbaLinesServer.Guardian.decode_and_verify(token, %{"typ" => "access"}) do
        {:ok, _claims} ->
            {:ok, socket}
        {:error, reason} ->
            Logger.info("invalid token #{inspect reason}")
            {:error, "invalid_token"}
      end
    end
  
    def connect(_params, _socket) do
      :error
    end
  
    # Socket id's are topics that allow you to identify all sockets for a
    # given user:
    #
    #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
    #
    # Would allow you to broadcast a "disconnect" event and terminate
    # all active sockets and channels for a given user:
    #
    #     NbaLinesServer.Endpoint.broadcast("users_socket:#{user.id}",
    #       "disconnect", %{})
    #
    # Returning `nil` makes this socket anonymous.
    def id(_socket), do: nil
  end