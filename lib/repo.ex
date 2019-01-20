defmodule NbaLinesServer.Repo do
    use Ecto.Repo,
      otp_app: :nba_lines_server,
      adapter: Ecto.Adapters.Postgres
end