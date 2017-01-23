# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_api,
  namespace: PhoenixAPI,
  ecto_repos: [PhoenixAPI.Repo]

# Configures the endpoint
config :phoenix_api, PhoenixAPI.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YMenOO07Phqjx4HpWoEjR5miByvw5FfWZ8AxC0JOjJLGuzOYl5f1pAOWfnDm6Ra8",
  render_errors: [view: PhoenixAPI.ErrorView, accepts: ~w(json)],
  pubsub: [name: PhoenixAPI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
