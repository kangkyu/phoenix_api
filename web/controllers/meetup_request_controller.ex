defmodule PhoenixAPI.MeetupRequestController do
  use PhoenixAPI.Web, :controller

  alias PhoenixAPI.MeetupRequest

  def index(conn, _params) do
    meetup_requests = Repo.all(MeetupRequest)
    render(conn, "index.json", meetup_requests: meetup_requests)
  end

  # ... START EDITS
  defp extract_view_filter_from(params) do
    stop_if_date_less_than = params["stop_if_date_less_than"]
    stop_if_date_greater_than = params["stop_if_date_greater_than"]
    desc = params["desc"]

    %{
      stop_if_date_less_than: stop_if_date_less_than,
      stop_if_date_greater_than: stop_if_date_greater_than,
      desc: desc
    }
  end

  def create(conn, %{"meetup_request" => meetup_request_params}) do
    initial_changeset = MeetupRequest.Changeset.initial(
      %MeetupRequest{}, meetup_request_params
    )

    result = if initial_changeset.valid? do
      MeetupRequest.exists? initial_changeset.changes
    else
      nil
    end

    view_filter = extract_view_filter_from meetup_request_params

    if result do
      render(conn, "show.json", meetup_request: result, filter: view_filter)
    else
      changeset = if initial_changeset.valid? do
        MeetupRequest.Changeset.final initial_changeset
      else
        initial_changeset
      end

      case Repo.insert(changeset) do
        {:ok, meetup_request} ->
          conn
          |> put_status(:created)
          |> put_resp_header(
            "location", meetup_request_path(conn, :show, meetup_request)
          )
          |> render(
            "show.json", meetup_request: meetup_request, filter: view_filter
          )
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(PhoenixAPI.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end
  # ... END EDITS

  def show(conn, %{"id" => id}) do
    meetup_request = Repo.get!(MeetupRequest, id)
    render(conn, "show.json", meetup_request: meetup_request)
  end

  def update(conn, %{"id" => id, "meetup_request" => meetup_request_params}) do
    raise inspect ["DEBUG/TODO", conn, id, meetup_request_params]

    # meetup_request = Repo.get!(MeetupRequest, id)
    # changeset = MeetupRequest.changeset(meetup_request, meetup_request_params)

    # case Repo.update(changeset) do
    #   {:ok, meetup_request} ->
    #     render(conn, "show.json", meetup_request: meetup_request)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(PhoenixAPI.ChangesetView, "error.json", changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    meetup_request = Repo.get!(MeetupRequest, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(meetup_request)

    send_resp(conn, :no_content, "")
  end
end
