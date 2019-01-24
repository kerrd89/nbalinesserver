defmodule NbaLinesServer.SessionController do
    @moduledoc """
    Provides the endpoint for login and logout for the V1 version of the
    API.
    When handling a `POST` request to `/api/v1/login` with a user name and
    password, a token will be returned as a JSON object.
    The user will then need to pass that token in the header to access the API.
    """
    require Logger
  
    use NbaLinesServer.Web, :controller
    alias NbaLinesServer.AuthenticationController
  
    @doc "Handle `POST` request to login with a JSON payload username/password"
    def login(conn, %{"email" => email, "password" => password}) do  
      login_result = AuthenticationController.api_login_by_email_and_pass(conn, email, password, [])

      case login_result do
        {:ok, token} -> json(conn, %{token: token})
        {:error, _reason, conn} ->
          conn
          |> put_status(302)
          |> json("Invalid email/password combination")
      end
    end
  
    @doc "Expire the users session and token"
    def logout(conn, %{"id" => _id}) do
      conn
      |> AuthenticationController.logout()
      |> json(%{"result" => %{
          "message" => "logged_out"
        }})
    end
  
    @doc "Handle any API authentication errors"
    def auth_error(conn, {type, reason}, _opts) do
      Logger.info("User accessing unauthorized app - #{inspect type}, #{inspect reason}")
      conn
      |> put_status(302)
      |> json("You are not authenticated")
    end
  end