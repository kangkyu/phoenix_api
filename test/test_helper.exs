# ...
{:ok, _} = Application.ensure_all_started(:ex_machina)

# ...
ExUnit.start(trace: true)
# ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(PhoenixAPI.Repo, :manual)

