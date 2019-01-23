defmodule NbaLinesServer.SessionControllerTest do
  use NbaLinesServer.ConnCase
  import NbaLinesServer.Factory

  alias Comeonin.Bcrypt

  setup do
    user = create(:user, session_count: 0, password: "password",
      password_hash: Bcrypt.hashpwsalt("password"))

    {:ok, %{user: user}}
  end

  test "POST /login should fail without proper credentials" do
    conn = post(build_conn(), session_path(build_conn(), :login), %{email: "fake", password: "fake"})
    assert json_response(conn, 302)
  end

  test "POST /login should give token with proper credentials", %{user: user} do
    conn = build_conn()
    |> put_req_header("content-type", "application/json")
    |> post(session_path(build_conn(), :login), %{email: user.email, password: user.password})

    assert json_response(conn, 200)
  end
end