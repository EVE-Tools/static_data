defmodule StaticData.HTTP do
  @moduledoc """
    Contains HTTP wrapping functionality.
  """

  alias Response

  require HTTPotion

  @user_agent Application.get_env(:static_data, :user_agent)

  @doc """
  Allows you to get parsed JSON from a URL. JSON is returned as a map.
  """
  @spec get(String.t) :: Map.t
  def get(url) do
    url
    |> do_get_request
    |> check_status_code
    |> decompress_response
    |> parse_json
  end

  @spec do_get_request(String.t) :: Response.t
  defp do_get_request(url) do
    headers = [{"Accept-Encoding", "gzip"},
               {"User-Agent", @user_agent}]

    HTTPotion.get(url, headers: headers)
  end

  @spec check_status_code(Response.t) :: Response.t
  defp check_status_code(response) do
    # Only accept 200
    200 = response.status_code

    response
  end

  @spec decompress_response(Response.t) :: Response.t
  defp decompress_response(response) do
    # Either its compressed with gzip or not, else crash
    case response.headers["Content-Encoding"] do
      "gzip" -> %{response | body: response.body |> :zlib.gunzip}
      nil    -> response
    end
  end

  @spec parse_json(Response.t) :: Map.t
  defp parse_json(response) do
    response.body |> :jiffy.decode([:return_maps])
  end
end
