defmodule CommcareAPI.MixProject do
  use Mix.Project

  @source_url "https://github.com/RatioPBC/commcare_api"
  @version "0.3.1"

  def project do
    [
      aliases: aliases(),
      app: :commcare_api,
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: ["test.ci": :test],
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  defp aliases do
    [
      "test.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "credo --strict",
        "test --raise",
        "dialyzer"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    "A small client for the CommCare API."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:euclid, "~> 0.2"},
      {:jason, "~> 1.0"},
      {:floki, ">= 0.30.0"},
      {:httpoison, "~> 1.6"},
      {:timex, "~> 3.7"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:hammox, "~> 0.5", only: [:test]},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.24.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    [
      ignore_warnings: "dialyzer.ignore",
      plt_add_apps: []
    ]
  end

  defp docs do
    [
      extras: extras(),
      formatters: ["html"],
      main: "readme",
      name: "CommCare API",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp extras do
    [
      "README.md",
      "LICENSE"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        GitHub: @source_url,
        Sponsor: "https://ratiopbc.com"
      },
      maintainers: ["Jesse Cooke"]
    ]
  end
end
