defmodule AppleIntentsJido.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/dl-alexandre/apple_intents"

  def project do
    [
      app: :apple_intents_jido,
      version: @version,
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      apple_intents_dep(),
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp apple_intents_dep do
    opts =
      if local_apple_intents?() and not hex_package_build?() do
        [path: "../apple_intents", override: true]
      else
        []
      end

    {:apple_intents, "~> 0.1.0", opts}
  end

  defp local_apple_intents? do
    System.get_env("HEX_PUBLISH") != "1" and
      File.exists?(Path.expand("../apple_intents/mix.exs", __DIR__))
  end

  defp hex_package_build? do
    System.get_env("HEX_PUBLISH") == "1" or
      Enum.any?(System.argv(), &(&1 in ["hex.build", "hex.publish"]))
  end

  defp description do
    "Jido integration for apple_intents — agent orchestration via Jido.Exec."
  end

  defp package do
    [
      name: "apple_intents_jido",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "apple_intents" => "https://hex.pm/packages/apple_intents"
      },
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE AGENTS.md docs .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE", "AGENTS.md", "docs/GUIDE.md"],
      source_ref: "v#{@version}",
      groups_for_modules: [
        Jido: [AppleIntents.Jido, AppleIntents.Jido.Default, AppleIntents.Jido.Context]
      ]
    ]
  end
end
