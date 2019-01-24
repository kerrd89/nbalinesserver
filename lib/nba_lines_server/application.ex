defmodule NbaLinesServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias NbaLinesServer.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Endpoint, []),
      # Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: NbaLinesServer.Router, options: [port: 8085]),
      supervisor(NbaLinesServer.Repo, []),
      worker(NbaLinesServer.QuantumScheduler, []),
      # worker(Guardian.DB.Token.SweeperServer, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NbaLinesServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
