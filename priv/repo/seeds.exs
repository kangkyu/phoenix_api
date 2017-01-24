# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixAPI.Repo.insert!(%PhoenixAPI.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# ...
defmodule Seeds do
  alias PhoenixAPI.Repo
  alias PhoenixAPI.MeetupRequest

  # import Ecto.Query
  require Ecto.Query

  def run do
    if delete_all?(), do: Repo.delete_all(MeetupRequest)
  end

  defp delete_all? do
    delete_evar = "delete"
    System.get_env delete_evar
  end
end

Seeds.run
