defmodule PhoenixAPI.MeetupRequest do
  use PhoenixAPI.Web, :model

  schema "meetup_requests" do
    field :endpoint, :string
    field :query, :string
    field :response, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:endpoint, :query, :response])
    |> validate_required([:endpoint, :query, :response])
  end
end
