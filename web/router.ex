defmodule PhoenixAPI.Router do
  use PhoenixAPI.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixAPI do
    pipe_through :api

    resources "/meetup_requests", MeetupRequestController, except: [:new, :edit]
  end
end
