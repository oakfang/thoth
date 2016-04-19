defmodule Thoth.Mixfile do
  use Mix.Project

  def project do
    [app: :thoth,
     description: "An Elixir digraph inspired local Graph DB",
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     consolidate_protocols: false,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp package do
    [maintainers: ["Alon Niv"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/oakfang/thoth"}]
  end
end
