defmodule EctoLoggerJson.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_logger_json,
      build_embedded: Mix.env == :prod,
      deps: deps,
      dialyzer: [
        plt_add_deps: true,
        plt_file: ".local.plt"
      ],
      description: "Overrides Ecto's LogEntry to format ecto logs as json",
      docs: [extras: ["README.md"]],
      elixir: "~> 1.2",
      homepage_url: "https://github.com/bleacherreport/ecto_logger_json",
      name: "Ecto Logger JSON",
      package: package,
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      source_url: "https://github.com/bleacherreport/ecto_logger_json",
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.1",
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo,       "~> 0.4",  only: [:dev]},
      {:dialyxir,    "~> 0.3",  only: [:dev]},
      {:earmark,     "~> 0.1",  only: [:dev]},
      {:excoveralls, "~> 0.5",  only: [:test]},
      {:ex_doc,      "~> 0.12", only: [:dev]},
      {:poison,      "~> 1.5 or ~> 2.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bleacherreport/ecto_logger_json"},
      maintainers: ["John Kelly"]
    ]
  end
end
