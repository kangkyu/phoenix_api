defmodule PhoenixAPI.MeetupRequestControllerTest do
  use PhoenixAPI.ConnCase

  alias PhoenixAPI.MeetupRequest
  @valid_attrs %{endpoint: "some content", query: "some content", response: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, meetup_request_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = get conn, meetup_request_path(conn, :show, meetup_request)
    assert json_response(conn, 200)["data"] == %{"id" => meetup_request.id,
      "endpoint" => meetup_request.endpoint,
      "query" => meetup_request.query,
      "response" => meetup_request.response}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, meetup_request_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(MeetupRequest, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, meetup_request_path(conn, :create), meetup_request: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(MeetupRequest, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = delete conn, meetup_request_path(conn, :delete, meetup_request)
    assert response(conn, 204)
    refute Repo.get(MeetupRequest, meetup_request.id)
  end
end
