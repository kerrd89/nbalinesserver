defmodule NbaLinesServer.MixProject do
  use Mix.Project

  @ignore_modules File.read!("./.coverignore")
  |> String.split("\n")
  |> Enum.reject(fn item -> String.contains?(item, "#") or item == "" end)
  |> Enum.map(&String.to_atom(&1))  

  def project do
    [
      app: :nba_lines_server,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      test_coverage: [
        tool: Coverex.Task,
        ignore_modules: @ignore_modules
      ],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: applications(Mix.env),
      mod: {NbaLinesServer.Application, []}
    ]
  end

  def applications(env) when env in [:test] do
    applications(:default) ++ [:ex_machina]
  end

  def applications(_) do
    [
      :phoenix,
      :phoenix_pubsub,
      :logger,
      :gettext,
      :cowboy,
      :plug,
      :poison,
      :comeonin,
      :cors_plug,
      :httpoison,
      :quantum
    ]
  end


  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1.1"},
      {:phoenix_ecto, "4.0.0"},
      {:phoenix_html, "2.13.1"},
      {:cowboy, "~> 2.6.0"},
      {:plug_cowboy, "~> 2.0.0"},
      {:plug, "~> 1.7"},
      {:poison, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14.1"},
      {:guardian, "1.2.1"},
      {:guardian_db, "2.0.0"},
      {:comeonin, "1.6.0"},
      {:gettext, "0.16.0"},
      {:cors_plug, "2.0.0"},
      {:httpoison, "~> 1.4"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},

      # test dependencies
      {:coverex, "~> 1.5.0", only: :test},
      {:ex_machina, "0.6.2", only: [:dev, :test]},
      # Recording API Requests
      {:exvcr, "~> 0.10", only: :test},
      {:ibrowse, "~> 4.4", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/repo_case.exs", "test/channel_case.exs", "test/factory.ex", "test/conn_case.exs"]
  defp elixirc_paths(_),     do: ["lib"]

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      server: ["phx.server"],
      s: ["phx.server"],
    ]
  end
end
