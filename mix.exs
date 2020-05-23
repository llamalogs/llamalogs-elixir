defmodule LlamaLogs.MixProject do
  use Mix.Project

  def project do
    [
      app: :llama_logs,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/llamalogs/llamalogs-elixir",
      homepage_url: "https://llamalogs.com"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # added influx here, seems cool to add libs
      mod: {LlamaLogs, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "Client for LlamaLogs service"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      # name: "postgrex",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end
end
