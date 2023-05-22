defmodule OckamKafkaOutlet.MixProject do
  use Mix.Project

  def project do
    [
      app: :ockam_kafka_outlet,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OckamKafkaOutlet.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ockam_cloud_node,
       git: "https://github.com/build-trust/ockam.git",
       branch: "develop",
       subdir: "implementations/elixir/ockam/ockam_cloud_node"},
      {:jason, "~> 1.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
