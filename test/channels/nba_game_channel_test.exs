defmodule NbaLinesServer.NbaGameChannelTest do
    use NbaLinesServer.ChannelCase

    import NbaLinesServer.Factory
  
    alias NbaLinesServer.NbaGameChannel
    alias NbaLinesServer.UserSocket
  
    setup do
        user = create(:user)     
  
        {:ok, user: user}
    end
  
    describe "join/3" do
        test "cannot join without the secret", %{user: user} do
            {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
            {:ok, socket} = socket(UserSocket)
            assert {:error, :secret_not_found} = subscribe_and_join(socket, NbaGameChannel, "nba_games", %{"guardian_token" => jwt})
        end
  
        test "authenticated_users recieve nba_games when they join the channel", %{user: user} do
            {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
    
            {:ok, socket} = connect(UserSocket, %{"guardian_token" => jwt}, %{})
            {:ok, payload, _socket} = subscribe_and_join(socket, NbaGameChannel, "nba_games", %{"guardian_token" => "#{jwt}"})
    
            # test alert_helper payload in alert_helper_test, here we just check it is returned
            nba_games = Date.utc_today() |> NbaGame.Api.get_nba_games_by_date()
    
            assert %{nba_games: nba_games} == payload
        end
    end
end