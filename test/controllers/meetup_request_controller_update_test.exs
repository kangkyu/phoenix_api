defmodule PhoenixAPI.MeetupRequestControllerUpdateTest do
  use PhoenixAPI.ConnCase

  # alias PhoenixAPI.MeetupRequest

  # # ...
  # import Mock
  # Code.require_file "test/mocks/httpotion_mock.exs"

  # Code.require_file "test/support/test_util.exs"
  # @no_mock PhoenixAPI.TestUtil.no_mock __ENV__.file

  # # Must be in sync with the URL used in the HTTP mock.
  # # The query property can be unsorted (alphabetically).
  # # The model sorts it before inserting in the DB.
  # @valid_attrs %{
  #   endpoint: "/la-fullstack/events",
  #   # endpoint: "/LearnTeachCode/events",
  #   query: "status=past"
  # }

  # @invalid_attrs %{}

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  test "updates and renders chosen resource when data is valid"
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   meetup_request = Repo.insert! %MeetupRequest{}
  #   conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]

  #   # ...
  #   assert_valid_request()
  #   # ... original
  #   # assert Repo.get_by(MeetupRequest, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   meetup_request = Repo.insert! %MeetupRequest{}
  #   conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end
end
