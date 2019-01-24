defmodule NbaLinesServer.UserChannelTest do
    use NbaLinesServer.ChannelCase

    import NbaLinesServer.Factory
  
    alias NbaLinesServer.UserSocket
    alias NbaLinesServer.UserChannel
  
    setup do
        user = create(:user)     
  
        {:ok, user: user}
    end
  
    describe "join/3" do
        test "empty params return plug authentication error" do
            socket = socket(UserSocket)
            assert {:error, :authentication_required} == subscribe_and_join(socket, UserChannel, "user:100", %{})
        end

        test "cannot join without a valid token", %{user: user} do
            # log someone in, to make sure we don't cross sessions
            {:ok, _jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
            socket = socket(UserSocket)

            assert {:error, "invalid_token"} == subscribe_and_join(socket, UserChannel, "user:#{user.id}", %{"guardian_token" => "dlfakjdlafjdk"})
        end
  
        test "authenticated_users recieve their own nba_lines when they join the channel", %{user: user} do
            other_user = create(:user)
            create(:nba_line, user: other_user)
            create(:nba_line, user: user)
            create(:nba_line, user: user)
            create(:nba_line, user: user)

            {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)

            socket = socket(UserSocket)
            {:ok, %{nba_lines: nba_lines_resp}, _socket} = subscribe_and_join(socket, UserChannel, "user:#{user.id}", %{"guardian_token" => "#{jwt}"})
    
            # test alert_helper payload in alert_helper_test, here we just check it is returned
            nba_lines = NbaLine.Api.get_nba_lines_by_user_id(user.id)

            assert Enum.count(nba_lines) == 3
            assert Enum.count(nba_lines_resp) == 3
            assert nba_lines_resp == nba_lines
        end
    end
end