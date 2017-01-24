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
      filter_response_data(
        meetup_request.response, params[:filter] || %{}
      )
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
      thing
    end

    ordered = if filter.desc do
      Enum.reverse filtered_list_of_things
    else
      filtered_list_of_things
    end

    Poison.encode! ordered
  end
  # ... END EDITS
end
