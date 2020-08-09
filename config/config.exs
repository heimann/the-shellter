# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :theshellter,
  ecto_repos: [Theshellter.Repo]

# Configures the endpoint
config :theshellter, TheshellterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1Ay+dECmF0uRA3yQ/O6detdyETa9kyYz7RJLW+InpuA/xcg7Ghwo53QVCD1QQhvS",
  render_errors: [view: TheshellterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Theshellter.PubSub,
  live_view: [signing_salt: "jhXsRaK/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Ueberauth configuration

config :ueberauth, Ueberauth,
  providers: [
    github:
      {Ueberauth.Strategy.Github, [default_scope: "user,public_repo", send_redirect_uri: false]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :theshellter, TheshellterWeb.Authentication,
  issuer: "theshellter",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
