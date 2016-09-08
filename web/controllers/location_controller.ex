defmodule StaticData.LocationController do
  @moduledoc """
  Contains controllers for the location endpoint. The client POSTs a list of
  location IDs it wants info for, the API returns that list from cache/CREST.
  """

  use StaticData.Web, :controller

  alias StaticData.HTTP

  @doc """
  Retrieve a list of locations by ID from post body.
  """
  def location(conn, %{"location_ids" => location_ids}) do
    location_ids = :jiffy.decode(location_ids)
    result = retrieve_locations(location_ids)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(200, result)
  end

  defp retrieve_locations(location_ids) do
    # Dedup array, dispatch async tasks for retrieval, await tasks, augment ID and encode as JSON
    # TODO: nag CCP about missing ID in location response
    location_ids
    |> Enum.dedup
    |> Enum.map(fn (location_id) ->
      {location_id, Task.async(fn -> get_location(location_id) end)}
    end)
    |> Enum.map(fn ({location_id, task}) ->
      {location_id, Task.await(task)}
    end)
    |> Enum.map(fn({location_id, location}) ->
      Map.put_new(location, "id", location_id)
    end)
    |> :jiffy.encode
  end

  defp get_location(location_id) when location_id > 1_000_000_000_000 do
    # Citadel
    ConCache.get_or_store(:dynamic_location_cache, location_id, fn() ->
      # Get Citadel from 3rd party API
      result = HTTP.get("https://stop.hammerti.me.uk/api/citadel/#{location_id}")
      # Get System from CREST for constellationID
      citadel = result[Integer.to_string(location_id)]
      system_id = citadel["systemId"]
      citadel_name = citadel["name"]
      system = CREST.get_location(system_id)

      Map.put(system, "station", %{"id" => location_id, "name" => citadel_name})
    end)
  end

  defp get_location(location_id) when location_id >= 6100000 do
    # Outpost
    ConCache.get_or_store(:dynamic_location_cache, location_id, fn() ->
      CREST.get_location(location_id)
    end)
  end

  defp get_location(location_id) do
    # Everything else
    ConCache.get_or_store(:static_location_cache, location_id, fn() ->
      CREST.get_location(location_id)
    end)
  end
end
