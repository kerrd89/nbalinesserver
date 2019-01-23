defmodule NbaLinesServer.ConnCase do
    @moduledoc """
    This module defines the test case to be used by
    tests that require setting up a connection.
    Such tests rely on `Phoenix.ConnTest` and also
    imports other functionality to make it easier
    to build and query models.
    Finally, if the test case interacts with the database,
    it cannot be async. For this reason, every test runs
    inside a transaction which is reset at the beginning
    of the test unless the test case is marked as async.
    """
    use ExUnit.CaseTemplate
  
    using do
      quote do
        # Import conveniences for testing with connections
        use Phoenix.ConnTest
  
        alias NbaLinesServer.Repo
        import Ecto.Schema, except: [build: 2]
        import Ecto.Query, only: [from: 2]
  
        import NbaLinesServer.Router.Helpers

        # The default endpoint for testing
        @endpoint NbaLinesServer.Endpoint
  
        # We need a way to get into the connection to login a user
        # We need to use the bypass_through to fire the plugs in the router
        # and get the session fetched.
        def guardian_login(%Plug.Conn{} = conn, user) do #, token, opts) do
          conn
            |> bypass_through(NbaLinesServer.Router, [:browser])
            |> get("/")
            |> NbaLinesServer.Guardian.Plug.sign_in(user)
            |> send_resp(200, "Flush the session yo")
            |> recycle()
        end
  
        def api_login(%Plug.Conn{} = conn, user) do
          {:ok, jwt, full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
  
          conn |> put_req_header("authorization", jwt)
        end
      end
    end
  
    setup tags do
      Ecto.Adapters.SQL.Sandbox.checkout(NbaLinesServer.Repo)
  
      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(NbaLinesServer.Repo, {:shared, self()})
      end
  
      {:ok, conn: Phoenix.ConnTest.build_conn()}
    end
  end