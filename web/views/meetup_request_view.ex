defmodule PhoenixAPI.MeetupRequestView do
  use PhoenixAPI.Web, :view

  def render("index.json", %{meetup_requests: meetup_requests}) do
    %{data: render_many(meetup_requests, PhoenixAPI.MeetupRequestView, "meetup_request.json")}
  end

  def render("show.json", %{meetup_request: meetup_request}) do
    %{data: render_one(meetup_request, PhoenixAPI.MeetupRequestView, "meetup_request.json")}
  end

  def render("meetup_request.json", %{meetup_request: meetup_request}) do
    %{id: meetup_request.id,
      endpoint: meetup_request.endpoint,
      query: meetup_request.query,
      response: meetup_request.response}
  end
end
