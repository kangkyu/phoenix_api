defmodule PhoenixAPI.Repo.Migrations.CreateMeetupRequest do
  use Ecto.Migration

  def change do
    create table(:meetup_requests) do
      add :endpoint, :string
      add :query, :string
      add :response, :text

      timestamps()
    end

    # ... added
    create index :meetup_requests, [:endpoint]
    create index :meetup_requests, [:query]
  end
end
