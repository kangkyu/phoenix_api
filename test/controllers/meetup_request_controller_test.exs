defmodule PhoenixAPI.MeetupRequestControllerTest do
  use PhoenixAPI.ConnCase

  alias PhoenixAPI.MeetupRequest

  # ... START EDITS
  import Mock
  Code.require_file "test/mocks/httpotion_mock.exs"

  Code.require_file "test/support/test_util.exs"
  @no_mock PhoenixAPI.TestUtil.no_mock __ENV__.file

  # Must be in sync with the URL used in the HTTP mock.
  # The query property can be unsorted (alphabetically).
  # The model sorts it before inserting in the DB.
  @valid_attrs %{
    endpoint: "/la-fullstack/events",
    # endpoint: "/LearnTeachCode/events",
    query: "status=past&desc=true"
  }
  # ... STOP EDITS

  @invalid_attrs %{}

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
  # test "shows chosen resource", %{conn: conn} do
  #   meetup_request = Repo.insert! %MeetupRequest{}
  #   conn = get conn, meetup_request_path(conn, :show, meetup_request)
  #   assert json_response(conn, 200)["data"] == %{"id" => meetup_request.id,
  #     "endpoint" => meetup_request.endpoint,
  #     "query" => meetup_request.query,
  #     "response" => meetup_request.response}
  # end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, meetup_request_path(conn, :show, -1)
    end
  end

  # ... EDITED BLOCK
  describe "** resource creation and update **" do
    defp assert_valid_request do
      got = MeetupRequest |> Ecto.Query.first |> Repo.one
      assert got.endpoint == @valid_attrs.endpoint
      assert URI.decode_query(got.query) == URI.decode_query(@valid_attrs.query)
    end

    @title "creates and renders resource when data is valid"
    if @no_mock do
      test @title, %{conn: conn} do
        conn = post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
        assert json_response(conn, 201)["data"]["id"]

        # ...
        assert_valid_request()
        # ... original
        # assert Repo.get_by(MeetupRequest, @valid_attrs)
      end
    else
      test_with_mock(
        @title, %{conn: conn},
        HTTPotion, [], [get: fn(url) -> HTTPotionMock.get(url) end]
      ) do
        conn = post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
        assert json_response(conn, 201)["data"]["id"]
        assert_valid_request()
      end
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, meetup_request_path(conn, :create), meetup_request: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

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
  # test "creates and renders resource when data is valid", %{conn: conn} do
  #   conn = post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
  #   assert json_response(conn, 201)["data"]["id"]
  #   assert Repo.get_by(MeetupRequest, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, meetup_request_path(conn, :create), meetup_request: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   meetup_request = Repo.insert! %MeetupRequest{}
  #   conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(MeetupRequest, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   meetup_request = Repo.insert! %MeetupRequest{}
  #   conn = put conn, meetup_request_path(conn, :update, meetup_request), meetup_request: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen resource", %{conn: conn} do
    meetup_request = Repo.insert! %MeetupRequest{}
    conn = delete conn, meetup_request_path(conn, :delete, meetup_request)
    assert response(conn, 204)
    refute Repo.get(MeetupRequest, meetup_request.id)
  end

  # ... NEW BLOCK
  # ... always mocked because we're not checking if the data is correct or not.
  describe "** when resource already exists **" do
    setup do
      {:ok, agent} = Agent.start_link fn -> 0 end
      {:ok, agent: agent}
    end

    defp state(url, agent) do
      Agent.update(agent, fn count -> count + 1 end)
      HTTPotionMock.get(url)
    end

    defp number_of_times_mocked_function_is_called(agent) do
      Agent.get(agent, &(&1))
    end

    test_with_mock(
      "it should not create the same resource",
      %{conn: conn, agent: agent},
      HTTPotion,
      [],
      [get: fn(url) -> state(url, agent) end]
    ) do
      assert number_of_times_mocked_function_is_called(agent) == 0
      count = Repo.all(MeetupRequest) |> length
      assert count == 0

      post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
      assert number_of_times_mocked_function_is_called(agent) == 1

      post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
      assert number_of_times_mocked_function_is_called(agent) == 1

      count = Repo.all(MeetupRequest) |> length
      assert count == 1
    end
  end
end
