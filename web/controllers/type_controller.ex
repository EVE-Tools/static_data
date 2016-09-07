defmodule StaticData.TypeController do
  @moduledoc """
  Contains controllers for the type endpoint. The client POSTs a list of
  type IDs it wants info for, the API returns that list from cache/CREST.
  """

  use StaticData.Web, :controller

  @doc """
  Retrieve a list of types by ID from post body.
  """
  def type(conn, %{"type_ids" => type_ids}) do
    type_ids = :jiffy.decode(type_ids)
    result = retrieve_types(type_ids)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(200, result)
  end

  defp retrieve_types(type_ids) do
    type_ids
    |> Enum.dedup
    |> Enum.map(fn (type_id) -> Task.async(fn -> get_type(type_id) end) end)
    |> Enum.map(fn (task) -> Task.await(task) end)
    |> :jiffy.encode
  end

  defp get_type(type_id) do
    # Get type from CREST if needed
    ConCache.get_or_store(:type_cache, type_id, fn() ->
      CREST.get_type(type_id)
    end)
  end
end
