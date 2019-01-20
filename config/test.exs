use Mix.Config

config :nba_lines_server, NbaLinesServer.Repo,
  database: "nba_lines_server_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :error