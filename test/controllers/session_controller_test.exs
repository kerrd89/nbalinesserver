defmodule NbaLinesServer.SessionControllerTest do
  use NbaLinesServer.ConnCase
  import NbaLinesServer.Factory

  setup do
    user = build(:user)

    changeset = NbaLinesServer.User.registration_changeset(%NbaLinesServer.User{}, %{
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "email" => user.email,
      "password" => user.password
    })

    user = NbaLinesServer.Repo.insert!(changeset)

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

    payload = conn.resp_body |> Poison.decode!

    refute is_nil(payload["token"])
  end
end