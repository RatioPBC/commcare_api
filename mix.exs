defmodule CommcareApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :commcare_api,
      deps: deps(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        files: ["lib", "mix.exs", "README.md", "version"]
      ],
      start_permanent: Mix.env() == :prod,
      version: version()
    ]
  end

  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      local_or_remote(:remote, :euclid,
        version: "~> 0.1",
        path: "../euclid"
      ),
      {:jason, "~> 1.0"},
      {:floki, ">= 0.0.0"},
      {:httpoison, "~> 1.6"},
      {:timex, "~> 3.5"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:hammox, "~> 0.2", only: [:test]},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp local_or_remote(:local, package, options) do
    {package, options |> Keyword.delete(:organization) |> Keyword.delete(:version)}
  end

  defp local_or_remote(:remote, package, options) do
    {package, options |> Keyword.get(:version), options |> Keyword.delete(:path) |> Keyword.delete(:version)}
  end

  defp version do
    case File.read("version") do
      {:error, _} -> "0.0.0"
      {:ok, version_number} -> String.trim(version_number)
    end
  end
end
