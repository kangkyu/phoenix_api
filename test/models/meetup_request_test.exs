defmodule PhoenixAPI.MeetupRequestTest do
  use PhoenixAPI.ModelCase

  alias PhoenixAPI.MeetupRequest

  # ... START EDITS
  import PhoenixAPI.MeetupRequest.Changeset, only: [initial: 2]

  import Mock
  Code.require_file "test/mocks/httpotion_mock.exs"

  Code.require_file "test/support/test_util.exs"
  @no_mock PhoenixAPI.TestUtil.no_mock __ENV__.file

  @valid_attrs %{
    endpoint: "/la-fullstack/events",
    query: %{"status" => "past"} |> URI.encode_query,
    response: "some content"
  }
  @invalid_attrs %{}

  describe "\b: changeset with valid attributes" do
    defp changeset do
      %MeetupRequest{}
        |> initial(@valid_attrs)
        |> MeetupRequest.Changeset.final
    end

    if @no_mock do
      test "\b> not mocked", do: assert changeset().valid?
    else
      test_with_mock "\b> mocked", HTTPotion, [
        get: fn(url) -> HTTPotionMock.get(url) end]
      do
        assert changeset().valid?
      end
    end
  end

  test "changeset with invalid attributes" do
    changeset = %MeetupRequest{} |> initial(@invalid_attrs)
    refute changeset.valid?
  end
  # ... END EDITS
end
