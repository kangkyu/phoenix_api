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
  # ... START EDITS
  defmodule Changeset do
    @query_key :query

    def initial(struct, params \\ %{}) do
      initial_changeset = struct
        |> cast(params, [:endpoint, @query_key])
        |> validate_required([:endpoint, @query_key])

      if initial_changeset.valid? do
        # ... apparently, encode_query sorts the keys.
        # https://hexdocs.pm/elixir/URI.html#encode_query/1
        sorted_query = initial_changeset.changes.query
          |> decode_query
          |> URI.encode_query

        initial_changeset |> change(query: sorted_query)
      else
        initial_changeset
      end
    end

    def final(initial_changeset) do
      initial_changeset
        |> change(response: Poison.encode!(PhoenixAPI.Response.get(
          initial_changeset.changes.endpoint,
          @query_key,
          decode_query(initial_changeset.changes.query)
        )))
    end

    defp decode_query(query_params) do
      query_params |> URI.decode_query |> Enum.map(
        fn({key, val}) ->
          case val do
             "true" -> {key, true}
             "false" -> {key, false}
             _ -> {key, val}
          end
        end
      )
    end
  end

  def exists?(changes) do
    PhoenixAPI.Repo.get_by(PhoenixAPI.MeetupRequest, %{
      endpoint: changes.endpoint, query: changes.query
    })
  end
  # ... END EDITS
end
