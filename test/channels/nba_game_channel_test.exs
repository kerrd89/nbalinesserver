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
        test "empty params return plug authentication error" do
            assert {:error, :authentication_required} == subscribe_and_join(socket(UserSocket), NbaGameChannel, "nba_games", %{})
        end

        test "cannot join without a valid token", %{user: user} do
            # log someone in, to make sure we don't cross sessions
            {:ok, _jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)
            socket = socket(UserSocket)

            assert {:error, "invalid_token"} == subscribe_and_join(socket, NbaGameChannel, "nba_games", %{"guardian_token" => "dlfakjdlafjdk"})
        end
  
        test "authenticated_users recieve nba_games when they join the channel", %{user: user} do
            create(:nba_game)
            create(:nba_game)
            create(:nba_game)
            test_game = create(:nba_game)
            NbaOfferedLine.Api.create_nba_offered_line(%{"nba_game_id" => test_game.id, "line" => 5.3})
            NbaOfferedLine.Api.create_nba_offered_line(%{"nba_game_id" => test_game.id, "line" => 5.6})

            {:ok, jwt, _full_claims} = NbaLinesServer.Guardian.encode_and_sign(user)

            socket = socket(UserSocket)
            {:ok, %{nba_games: nba_games_resp}, _socket} = subscribe_and_join(socket, NbaGameChannel, "nba_games", %{"guardian_token" => "#{jwt}"})
    
            # test alert_helper payload in alert_helper_test, here we just check it is returned
            nba_games = Date.utc_today() |> NbaGame.Api.get_nba_games_by_date()

            assert Enum.count(nba_games) == 4
            assert Enum.count(nba_games_resp) == 4
            assert nba_games_resp == nba_games

            Enum.each(nba_games_resp, fn(nba_game_resp) ->
                if nba_game_resp.id === test_game.id do
                    assert Enum.count(nba_game_resp.nba_offered_lines) == 2
                end
            end)
        end
    end
end