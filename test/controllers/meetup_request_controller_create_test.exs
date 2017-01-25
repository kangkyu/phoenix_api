
defmodule PhoenixAPI.MeetupRequestControllerCreateTest do
  use PhoenixAPI.ConnCase

  alias PhoenixAPI.MeetupRequest

  # ...
  import Mock
  Code.require_file "test/mocks/httpotion_mock.exs"

  Code.require_file "test/support/test_util.exs"
  @no_mock PhoenixAPI.TestUtil.no_mock __ENV__.file

  # Must be in sync with the URL used in the HTTP mock.
  # The query property can be unsorted (alphabetically).
  # The model sorts it before inserting in the DB.
  @valid_attrs %{
    endpoint: "/la-fullstack/events",
    query: "status=past"
  }

  @filtered_view %{
    filter: %{stop_if_date_greater_than: 1474507800000},
    expected: %{
      length: 14,
      id: %{first: "xcmqrlyvfbfc", last: "vmtswlyvmbkb"}
    }
  }

  @expected_data_length if @no_mock, do: 26, else: 26 # The count of number of events.
  @expected_first_id "xcmqrlyvfbfc" # The first event, chrono ordered. This shouldn't change.

  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "\b: when resource doesn't exist" do
    defp assert_valid_request do
      got = MeetupRequest |> Ecto.Query.first |> Repo.one
      assert got.endpoint == @valid_attrs.endpoint

      data = Poison.decode! got.response
      # If this fails, check if a new item to the list (meetup event) has been
      #   added. Update the @expected_data_length accordingly.
      assert length(data) == @expected_data_length

      assert (data |> List.first |> Map.fetch!("id")) == @expected_first_id

      assert URI.decode_query(got.query) == URI.decode_query(@valid_attrs.query)
    end

    @title "\b, when data is valid> creates & renders resource"
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
      setup %{conn: conn} do
        with_mock HTTPotion, [get: fn(url) -> HTTPotionMock.get(url) end] do
          {:ok, conn: post(
            conn,
            meetup_request_path(conn, :create),
            meetup_request: @valid_attrs
          )}
        end
      end

      test @title <> " - status 201", %{conn: conn} do
        assert json_response(conn, 201)["data"]["id"]
      end

      test @title <> " - data received is valid" do
        assert_valid_request()
      end

      # test_with_mock(
      #   @title, %{conn: conn},
      #   HTTPotion, [], [get: fn(url) -> HTTPotionMock.get(url) end]
      # ) do
      #   conn = post conn, meetup_request_path(conn, :create), meetup_request: @valid_attrs
      #   assert json_response(conn, 201)["data"]["id"]
      #   assert_valid_request()
      # end
    end

    test "\b, when data is invalid> doesn't create resource & renders errors", %{conn: conn} do
      conn = post conn, meetup_request_path(conn, :create), meetup_request: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # ... always mocked because we're not checking if the data is correct or not.
  describe "\b: when resource already exists" do
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
      "\b> it shouldn't create resource",
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

  # ... should be OK to always be mocked. The non-mocked tests above should suffice.
  describe "\b: retrieving resource with view filters (stop at date)" do
    setup %{conn: conn} do
      with_mock HTTPotion, [get: fn(url) -> HTTPotionMock.get(url) end] do
        conn = post(
          conn,
          meetup_request_path(conn, :create),
          meetup_request: Map.merge(@valid_attrs, @filtered_view.filter)
        )

        data = json_response(conn, 201)["data"]["data"] |> Poison.decode!

        {:ok, data: data}
      end
    end

    test "\b> data (events) count == #{@filtered_view.expected.length}", %{data: data} do
      assert length(data) == @filtered_view.expected.length
    end

    test "\b> first ID == #{@filtered_view.expected.id.first}", %{data: data} do
      assert (data |> List.first |> Map.fetch!("id")) == @filtered_view.expected.id.first
    end

    test "\b> last ID == #{@filtered_view.expected.id.last}", %{data: data} do
      assert (data |> List.last |> Map.fetch!("id")) == @filtered_view.expected.id.last
    end
  end

  # ... should be OK to always be mocked.
  #   The bullcrap meetup.com thing.
  Code.require_file "test/mocks/httpotion_ltc_mock.exs"

  describe "\b: special test for link-next-status-difference" do
    setup %{conn: conn} do
      with_mocks([
        {HTTPotion, [], [get: fn(url) -> HTTPotionLTCMock.get(url) end]},
        {Process, [:passthrough], [sleep: fn(delay) -> delay end]}
      ]) do
        conn = post(
          conn,
          meetup_request_path(conn, :create),
          meetup_request: Map.merge(
            @valid_attrs, %{endpoint: "/LearnTeachCode/events"}
          )
        )

        data = json_response(conn, 201)["data"]["data"] |> Poison.decode!

        {:ok, data: data}
      end
    end

    @expected %{
      length: 331, id: %{first: "220210343", last: "dtxkkmywcbwb" }
    }

    test "\b> length == #{@expected.length}", %{data: data} do
      assert length(data) == @expected.length
    end

    test "\b> first ID == #{@expected.id.first}", %{data: data} do
      assert (data |> List.first |> Map.fetch!("id")) == @expected.id.first
    end

    test "\b> last ID == #{@expected.id.last}", %{data: data} do
      assert (data |> List.last |> Map.fetch!("id")) == @expected.id.last
    end
  end
end
