defmodule NuAuthorizer.MixProject do
  use Mix.Project

  def project do
    [
      app: :authorizer,
      version: "0.1.0",
      elixir: "~> 1.11",
      escript: [main_module: NuAuthorizer.CLI],
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib","test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:pipe_to, "~> 0.2"},
      {:mock, "~> 0.3.6", only: :test},
    ]
  end
end
