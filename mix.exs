defmodule Thoth.Mixfile do
  use Mix.Project

  def project do
    [app: :thoth,
     description: "An Elixir digraph inspired local Graph DB",
     version: "0.0.3",
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

  defp deps do
    []
  end

  defp package do
    [maintainers: ["Alon Niv"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/oakfang/thoth"}]
  end
end
