defmodule UserTest do
  use NbaLinesServer.RepoCase

  import NbaLinesServer.Factory

  describe "get_user_by_id/1" do
    test "returns a user if one exists" do
      user = create(:user)

      db_user = User.Api.get_user_by_id(user.id) 

      assert db_user.id == user.id
      assert db_user.email == user.email
      assert db_user.first_name == user.first_name
      assert db_user.last_name == user.last_name
    end

    test "returns nil if no user exists" do
      assert User.Api.get_user_by_id(1000) == nil
    end
  end

  describe "create_user/1" do
    test "returns a user if passed valid params" do
      email = "test@test.com"
      first_name = "joe"
      last_name = "bloe"
      password = "temp1234"

      {:ok, user} = User.Api.create_user(%{
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "password" => password
      })

      assert user.email == email
      assert user.first_name == first_name
      assert user.last_name == last_name
      assert user.password == password
      assert user.password_hash
      refute user.deleted
      assert user.inserted_at
      assert user.updated_at
    end

    test "returns an error about correct missing params" do
      {:error, error} = User.Api.create_user(%{})

      assert error == [
        first_name: {"can't be blank", [validation: :required]},
        last_name: {"can't be blank", [validation: :required]},
        email: {"can't be blank", [validation: :required]}
      ]
    end

    test "enforces password minimum of 6" do
      email = "test@test.com"
      first_name = "joe"
      last_name = "bloe"
      password = "temp1"

      {:error, error} = User.Api.create_user(%{
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "password" => password
      })

      assert error == [
        password: {"should be at least %{count} character(s)",
         [count: 6, validation: :length, kind: :min]}
      ]
    end

    test "enforces unique requirement on emails" do
      user = create(:user)

      {:error, error} = User.Api.create_user(%{
        "email" => user.email,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "password" => "temp1234"
      })

      assert error == "email taken"
    end
  end
end