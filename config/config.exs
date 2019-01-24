# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :nba_lines_server, NbaLinesServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "nba_lines_server_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :nba_lines_server, ecto_repos: [NbaLinesServer.Repo]

if Mix.env != :test do
  config :nba_lines_server, NbaLinesServer.QuantumScheduler,
    jobs: [
      sync_nba_games: [
        schedule: "*/20 * * * *",
        task: {NbaLinesServer.SyncHelper, :sync_nba_games, []}
      ]
    ]
else
  # Disable all cron tasks in test environment.
  config :nba_lines_server, NbaLinesServer.QuantumScheduler,
    jobs: []
end


import_config "#{Mix.env()}.exs"
