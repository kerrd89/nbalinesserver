defmodule UserTest do
  use NbaLinesServer.RepoCase

  describe "get_user_by_id/1" do
    test "returns a user if one exists" do
      {:ok, user} = create_default_user()

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
end