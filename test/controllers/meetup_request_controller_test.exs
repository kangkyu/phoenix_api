defmodule PhoenixAPI.MeetupRequestControllerTest do
  use PhoenixAPI.ConnCase

  alias PhoenixAPI.MeetupRequest

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, meetup_request_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  # ... THIS BLOCK EDITED
  test "shows chosen resource", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = get conn, meetup_request_path(conn, :show, meetup_request)
    assert json_response(conn, 200)["data"] == %{"id" => meetup_request.id,
      "endpoint" => meetup_request.endpoint,
      "query" => meetup_request.query,

      # ...
      "data" => meetup_request.response}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, meetup_request_path(conn, :show, -1)
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = delete conn, meetup_request_path(conn, :delete, meetup_request)
    assert response(conn, 204)
    refute Repo.get(MeetupRequest, meetup_request.id)
  end
end
