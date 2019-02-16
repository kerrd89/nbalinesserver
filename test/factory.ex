defmodule NbaLinesServer.Factory do
    use ExMachina.Ecto, repo: NbaLinesServer.Repo
  
    alias NbaLinesServer.NbaGame
    alias NbaLinesServer.NbaLine
    alias NbaLinesServer.NbaOfferedLine
    alias NbaLinesServer.User

    def factory(:user) do
        %User{
            email: "test@test.com",
            first_name: "joe",
            last_name: "bloe",
            password: "temp1234",
            deleted: false
        }
    end

    def factory(:nba_game) do
        %NbaGame{
            date: Date.utc_today(),
            home_team: "cavs",
            away_team: "bulls",
            event_id: "lakdfjldkfjaldkf"
        }
    end

    def factory(:completed_nba_game) do
        %NbaGame{
            date: Date.utc_today(),
            home_team: "cavs",
            away_team: "bulls",
            home_team_score: 102,
            away_team_score: 100,
            completed: true,
            event_id: "lakdfjldkfjaldkf"
        }
    end

    def factory(:nba_offered_line) do
        %NbaOfferedLine{
            nba_game: create(:nba_game),
            line: -5.2
        }
    end

    def factory(:nba_line) do
        %NbaLine{
            nba_game: create(:nba_game),
            user: create(:user),
            bet: true,
            nba_offered_line: create(:nba_offered_line)
        }
    end

    def factory(:event) do
        %{
            event_id: "lakdfjldkfjaldkf",
            home_team: "CLE",
            away_team: "WAS",
            avg_line: 1.43
        }
    end
end  