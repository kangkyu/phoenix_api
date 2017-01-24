defmodule PhoenixAPI.MeetupRequestView do
  use PhoenixAPI.Web, :view

  # ... START EDITS
  def render("index.json", %{meetup_requests: meetup_requests}) do
    %{data: render_many(
      meetup_requests, PhoenixAPI.MeetupRequestView, "meetup_request.json")}
  end

  def render("show.json", params) do
    meetup_request = params.meetup_request

    data = if meetup_request.response do
      filter_response_data(meetup_request.response, params[:filter] || %{})
    else
      nil
    end

    filtered_response = %{meetup_request | response: data}

    %{
      data: render_one(
        filtered_response, PhoenixAPI.MeetupRequestView, "meetup_request.json"
      )
    }
  end

  def render("meetup_request.json", %{meetup_request: meetup_request}) do
    %{id: meetup_request.id,
      endpoint: meetup_request.endpoint,
      query: meetup_request.query,
      data: meetup_request.response}
  end

  defp filter_response_data(response, nil), do: response
  defp filter_response_data(response, filter) do
    list_of_things = Poison.decode! response

    stop_if_date_less_than = Map.get(
      filter, :stop_if_date_less_than
    ) || 0

    stop_if_date_greater_than = Map.get(
      filter, :stop_if_date_greater_than
    ) || :infinity

    filtered_list_of_things = for thing <- list_of_things,
      unix_time = thing["time"],
      utc_offset = thing["utc_offset"],
      unix_time && utc_offset,
      (
        (unix_time > stop_if_date_less_than) &&
        (unix_time < stop_if_date_greater_than)
      )
    do
      # For DEBUGGING, delete later
      # utc_offset = div(Map.fetch!(thing, "utc_offset"), 1000)
      # unix_time = Map.fetch!(thing, "time")
      # date_time = DateTime.from_unix!(div(unix_time, 1000) + utc_offset)
      # # zone = %{time_zone: "America/Los_Angeles", zone_abbr: "PST"}
      # zone = %{time_zone: "", zone_abbr: ""}
      # date_time = date_time |> Map.merge(zone)
      # title = thing["name"]

      # IO.inspect([
      #   # thing
      #   unix_time: unix_time,
      #   # stop_before: stop_before,
      #   # stop_after: stop_after,
      #   title: title,
      #   # title: Map.fetch!(thing, "name"),
      #   date: DateTime.to_string(date_time)
      # ],
      #   width: 140
      # )

      thing
    end

    Poison.encode! filtered_list_of_things
  end

  # # ... original
  # def render("index.json", %{meetup_requests: meetup_requests}) do
  #   %{data: render_many(meetup_requests, PhoenixAPI.MeetupRequestView, "meetup_request.json")}
  # end

  # def render("show.json", %{meetup_request: meetup_request}) do
  #   %{data: render_one(meetup_request, PhoenixAPI.MeetupRequestView, "meetup_request.json")}
  # end

  # def render("meetup_request.json", %{meetup_request: meetup_request}) do
  #   %{id: meetup_request.id,
  #     endpoint: meetup_request.endpoint,
  #     query: meetup_request.query,
  #     response: meetup_request.response}
  # end
  # ... END EDITS
end
