defmodule NbaLinesServer.ChannelCase do
    @moduledoc """
    This module defines the test case to be used by
    channel tests.
    Such tests rely on `Phoenix.ChannelTest` and also
    imports other functionality to make it easier
    to build and query models.
    Finally, if the test case interacts with the database,
    it cannot be async. For this reason, every test runs
    inside a transaction which is reset at the beginning
    of the test unless the test case is marked as async.
    """
  
    use ExUnit.CaseTemplate
    use Phoenix.ChannelTest

    alias NbaLinesServer.NbaLineChannel
    alias NbaLinesServer.NbaGameChannel
    alias NbaLinesServer.UserSocket
  
    @endpoint NbaLinesServer.Endpoint
  
    using do
      quote do
        # Import conveniences for testing with channels
        use Phoenix.ChannelTest
  
        alias NbaLinesServer.Repo
        import Ecto.Schema
        import Ecto.Query, only: [from: 2]
        import NbaLinesServer.ChannelCase
    
        # The default endpoint for testing
        @endpoint NbaLinesServer.Endpoint
      end
    end
  
    setup tags do
      Ecto.Adapters.SQL.Sandbox.checkout(NbaLinesServer.Repo)
  
      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(NbaLinesServer.Repo, {:shared, self()})
      end
  
      :ok
    end

    @type channel_type :: NbaLineChannel | NbaGameChannel
    
    @doc "Connect a socket to be used in tests"
    @spec listen_to_socket(user :: %NbaLinesServer.User{}, channel :: channel_type, topic :: binary())
      :: Phoenix.Socket.t
    def listen_to_socket(user, channel, topic \\ nil) do
        {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
  
        {:ok, socket} = connect(UserSocket, %{"guardian_token" => jwt}, %{})
        {:ok, _, socket} = subscribe_and_join(socket, channel, topic, %{"guardian_token" => "#{jwt}"})
  
        socket
    end
  end