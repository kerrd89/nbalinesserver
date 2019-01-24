defmodule NbaLinesServer.AuthenticationController do
    @moduledoc """
    Provides methods to login a user by email and password both for the web
    browsers and external API integration endpoints.
    """
  
    import Comeonin.Bcrypt, only: [checkpw: 2]
    
    alias NbaLinesServer.Guardian.Plug
    alias NbaLinesServer.Repo

    # @doc "Login by HTTP POST parameters"
    # def login(conn, user) do
    #   conn
    #   |> assign(:current_user, user)
    #   |> Plug.sign_in(user)
    #   |> configure_session(renew: true)
    # end

    def logout(conn) do
      conn
      |> Plug.sign_out()
    end
  
    @doc "Login by API email and password to generate and return a token"
    def api_login_by_email_and_pass(conn, email, password, _opts) do
      user = Repo.get_by(NbaLinesServer.User, email: email)
 
      cond do
        not is_nil(user) && !user.deleted && checkpw(password, user.password_hash) ->
          {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
          {:ok, jwt}
        user ->
          {:error, :unauthorized, conn}
        true ->
          {:error, :not_found, conn}
      end
    end
  end