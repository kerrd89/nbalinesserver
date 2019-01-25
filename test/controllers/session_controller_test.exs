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

  # guard this with a token shared with application, so users can't be created dynamically
  test "POST /register should fail without proper credentials" do
    params = %{email: "fake@fake.com", password: "fake"}
    conn = post(build_conn(), session_path(build_conn(), :register), params)

    assert json_response(conn, 302)

    payload = conn.resp_body |> Poison.decode!
    # check not logged in with token
    assert is_nil(payload["token"])
    # check error message
    assert payload["reasons"] == [%{"password" => "should be at least %{count} character(s)"}, %{"first_name" => "can't be blank"}, %{"last_name" => "can't be blank"}]
  end

  test "POST /register should pass with valid params" do
    email = "fake@fake.com"
    pw = "temp1234"
    first_name = "jane"
    last_name = "dooe"
    params = %{email: email, password: pw, first_name: first_name, last_name: last_name}

    conn = post(build_conn(), session_path(build_conn(), :register), params)

    assert json_response(conn, 200)

    payload = conn.resp_body |> Poison.decode!
    refute is_nil(payload["token"])
    user_resp = payload["user"]

    # optional params to show several screens of instruction
    assert user_resp["first_name"] == first_name
    assert user_resp["last_name"] == last_name
    assert user_resp["email"] == email
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
    user_resp = payload["user"]

    refute is_nil(payload["token"])

    assert user_resp["id"] == user.id
    assert user_resp["first_name"] == user.first_name
    assert user_resp["last_name"] == user.last_name
    assert user_resp["email"] == user.email
  end
end