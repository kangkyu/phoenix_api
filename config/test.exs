use Mix.Config

# ... put in front so it can be overridden if need be.
import_config "SECRET_DO_NOT_GIT.exs"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_api, PhoenixAPI.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phoenix_api, PhoenixAPI.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "phoenix",
  password: "phoenix",
  database: "phoenix_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# ... for disabling mocking.
# `nomock=1 mix test` should retrieve online resources.
config :phoenix_api, :no_mock_evar, "nomock"
