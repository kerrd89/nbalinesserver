defmodule NbaLinesServer.SessionControllerTest do
  use NbaLinesServer.ConnCase
  import NbaLinesServer.Factory

  alias Comeonin.Bcrypt
  alias NbaLinesServer.GuardianToken
  alias NbaLinesServer.Repo

  setup do
    user = create(:user, session_count: 0, password: "password",
      password_hash: Bcrypt.hashpwsalt("password"))

    {:ok, %{user: user}}
  end

  test "POST /authenicate creates a session for a user",
    %{user: user}
  do
    # First ensure we have no current guardian tokens.
    tokens = Repo.all(GuardianToken)
    assert tokens == []

    # confirm we are getting an html response on a valid login attempt
    conn = post(build_conn(), session_path(build_conn(), :create),
      %{"session" => %{"email" => user.email, "password" => "password"}})

    assert html_response(conn, 302)

    tokens = Repo.all(GuardianToken)
    assert tokens != []

    # Ensure we have tokens properly set with issuer and audience.
    # These are needed by Guardian DB to verify the user is valid.
    Enum.each(tokens, fn(token) ->
      assert token.aud
      assert token.iss
    end)
  end
end