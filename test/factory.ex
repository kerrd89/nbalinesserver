defmodule NbaLinesServer.Factory do
    use ExMachina.Ecto, repo: NbaLinesServer.Repo
  
    alias NbaLinesServer.NbaGame
    alias NbaLinesServer.NbaLine
    alias NbaLinesServer.User

    def factory(:nba_game) do
        %NbaGame{
            date: Date.utc_today(),
            home_team: "cavs",
            away_team: "bulls"
        }
    end

    def factory(:completed_nba_game) do
        %NbaGame{
            date: Date.utc_today(),
            home_team: "cavs",
            away_team: "bulls",
            home_team_score: 102,
            away_team_score: 100,
            completed: true
        }
    end

    def factory(:nba_line) do
        %NbaLine{
            nba_game: create(:nba_game),
            user: create(:user),
            line: -5,
            bet: true
        }
    end

    def factory(:user) do
        %User{
            email: "test@test.com",
            first_name: "joe",
            last_name: "bloe",
            password: "temp1234",
            deleted: false
        }
    end
end  