Code.compiler_options(on_undefined_variable: :warn)

defmodule ElixirAoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_aoc,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:advent_of_code_utils, "~> 4.0"},
      {:json, "~> 1.4"},
      {:priority_queue, "~> 1.0"}
    ]
  end
end
