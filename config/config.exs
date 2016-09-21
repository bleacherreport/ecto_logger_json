use Mix.Config

config :logger, :console,
  format: "$message\n",
  level: :debug,
  metadata: [:request_id]
