defmodule NbaLinesServer.Authentication do
    @moduledoc """
    Provides methods to login a user by email and password both for the web
    browsers and external API integration endpoints.
    """
  
    import Plug.Conn
    import Comeonin.Bcrypt, only: [checkpw: 2]
    alias NbaLinesServer.Guardian.Plug
    
    @doc "Login by HTTP POST parameters"
    def login(conn, user) do
      conn
      |> assign(:current_user, user)
      |> Plug.sign_in(user)
      |> configure_session(renew: true)
    end
  
    def logout(conn) do
      conn
      |> Plug.sign_out()
    end
  
    @doc """
    Login by API JSON parameters for user name and password to set up a
    users session and ensure they are logged in.
    """
    def login_by_email_and_pass(conn, email, given_pass, opts) do
      repo = Keyword.fetch!(opts, :repo)
      user = repo.get_by(NbaLinesServer.User, email: email)
  
      cond do
        user && !user.deleted && checkpw(given_pass, user.password_hash) ->
          {:ok, login(conn, user)}
        user ->
          {:error, :unauthorized, conn}
        true ->
          {:error, :not_found, conn}
      end
    end
  
    @doc "Login by API email and password to generate and return a token"
    def api_login_by_email_and_pass(conn, email, password, opts) do
      repo = Keyword.fetch!(opts, :repo)
      user = repo.get_by(NbaLinesServer.User, email: email)
      cond do
        user && checkpw(password, user.password_hash) ->
          {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
          {:ok, jwt}
        user ->
          {:error, :unauthorized, conn}
        true ->
          {:error, :not_found, conn}
      end
    end
  end