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
      extra_applications: [:phoenix, :phoenix_pubsub, :logger, :gettext, :cowboy, :plug, :poison, :comeonin],
      mod: {NbaLinesServer.Application, []}
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

      # test dependencies
      {:coverex, "~> 1.5.0", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/repo_case.exs"]
  defp elixirc_paths(_),     do: ["lib"]

  defp aliases do
    [
     test: ["ecto.create --quiet", "ecto.migrate", "test"],
    ]
  end
end
