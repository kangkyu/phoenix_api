defmodule PhoenixAPI.MeetupRequestTest do
  use PhoenixAPI.ModelCase

  alias PhoenixAPI.MeetupRequest

  @valid_attrs %{endpoint: "some content", query: "some content", response: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MeetupRequest.changeset(%MeetupRequest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MeetupRequest.changeset(%MeetupRequest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
