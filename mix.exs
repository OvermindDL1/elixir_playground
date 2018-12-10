defmodule ElixirPlayground.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixir_playground,
      version: "0.0.1",
      elixir: "~> 1.7.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:benchee,     "~> 0.13.2"},
      {:benchee_csv, "~> 0.8.0"},
      {:benchee_html, "~> 0.5.0"},
      {:benchee_json, "~> 0.5.0"},
    ]
  end

  defp aliases do
    [
      bench: &bench/1
    ]
  end

  defp bench(arglist) do
    Mix.Tasks.Run.run(["bench/bench.exs" | arglist])
  end
end
