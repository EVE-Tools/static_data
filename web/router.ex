defmodule StaticData.Router do
  use StaticData.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/static-data/v1", StaticData do
    pipe_through :api

    post "/location", LocationController, :location
    post "/type", TypeController, :type
  end
end
