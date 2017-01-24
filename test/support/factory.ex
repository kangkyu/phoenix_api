
# defmodule PhoenixAPI.Factory do
#   use ExMachina.Ecto, repo: PhoenixAPI.Repo

#   def request_factory do
#     endpoint = "/la-fullstack/events"
#     query = "status=past&desc=true"

#     # @valid_attrs %{
#     #   endpoint: "/la-fullstack/events",
#     #   # endpoint: "/LearnTeachCode/events",
#     #   query: "status=past&desc=true"
#     # }

#     # signed_url = "https://api.meetup.com/2/events?offset=0&format=json&" <>
#     #   "limited_events=False&group_urlname=la-fullstack&" <>
#     #   "photo-host=public&page=20&fields=&" <>
#     #   "omit=description%2Chow_to_find_us&order=time&status=past&" <>
#     #   "desc=true&sig_id=201611406&sig=5c2f125a01dca375be34d4630aa3f4ff235488b1"

#     %PhoenixAPI.MeetupRequest{
#       endpoint: endpoint,
#       query: query,

#       # # ... hack - careful with this.
#       # # Waiting for this feature:
#       # #   https://github.com/thoughtbot/ex_machina/pull/131
#       # #   Related issue/feature request:
#       # #     https://github.com/thoughtbot/ex_machina/issues/180
#       # # The SOP is to give group_urlname, status and desc.
#       # #   The app will figure out unique_id_hack and signed_url.
#       # #   In this factory, we're giving it a value.
#       # #   So if you create a resource through this factory,
#       # #   and your inputs are the three attributes mentioned above,
#       # #   your unique_id_hack will differ.
#       # unique_id_hack: PhoenixAPI.MeetupRequest.get_unique_id_hack(%{
#       #   "group_urlname" => group_urlname,
#       #   "status" => status,
#       #   "desc" => desc
#       # }),

#       # signed_url: signed_url
#     }
#   end
# end
