defmodule Conduit.Mixfile do
  use Mix.Project

  def project do
    [app: :conduit,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     consolidate_protocols: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),
    do: elixirc_paths(:dev) ++ ["test/support", "test/support/messages"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:poison, "~> 2.2.0"},
     {:mix_test_watch, "~> 0.2.6", only: [:test, :dev]}]
  end

end
