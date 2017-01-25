defmodule PhoenixAPI.Response do
  require Logger

  def get(endpoint, query_key, decoded_query_params) do
    query = Map.merge(%{
      key: Application.fetch_env!(:phoenix_api, :secret) |> Keyword.fetch!(:key),
      sign: true,
      omit: "description,how_to_find_us",
      page: 200
    }, decoded_query_params |>
      Enum.reduce(
        %{}, fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
      )
    )

    uri = %URI{}
      |> Map.merge(%{
        scheme: "https", host: "api.meetup.com", authority: "api.meetup.com"
      })
      |> Map.merge(%{path: endpoint})
      |> Map.merge(%{query_key => URI.encode_query(query) })

    fetch [], URI.to_string(uri), decoded_query_params
  end

  defmodule HeaderLink do
    def extract_from(nil), do: nil
    def extract_from(headers_link) do
      sanitized_headers_link = cond do
        is_binary(headers_link) -> [headers_link]
        is_list(headers_link) -> headers_link
      end

      next = "next"

      Enum.find_value(sanitized_headers_link, fn(str) ->
        link = Regex.named_captures(
          ~r/<(?<url>[^>]+)>; \s* rel="(?<rel>[^"]*)"/x, str
        ) |> Enum.reduce(
          %{},
          fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
        )

        if !link, do: raise "No link match"

        valid_rel_values = [next, "prev"]
        if !Enum.member?(valid_rel_values, link.rel) do
          raise "'#{link.rel}' not a valid rel value... " <>
            "#{inspect valid_rel_values}"
        end

        if link.rel == next, do: link.url, else: nil
      end)
    end
  end

  defp fetch(data, nil, _), do: data
  defp fetch(data, url, decoded_query_params)do
    Logger.debug "... before HTTP client get URL '#{url}'"
    response = HTTPotion.get url
    Logger.debug "... after HTTP client get"

    next_url = HeaderLink.extract_from response.headers["link"]

    if next_url, do: Process.sleep(3000 + :rand.uniform(2000))

    decoded_list = Poison.decode!(response.body)

    only_expected_status_list = status_bullcrap_api(
      decoded_list, decoded_query_params
    )

    if only_expected_status_list do
      fetch(data ++ only_expected_status_list, nil, decoded_query_params)
    else
      fetch(data ++ decoded_list, next_url, decoded_query_params)
    end
  end

  # Why all this? Because bullsh*t meetup.com API. If you're looking for status=past
  #   it does not stop even if you've gotten all the past status. You'll end up
  #   getting a mix of past and upcoming status events.
  @status_key "status"
  def status_bullcrap_api(decoded_list, decoded_query_params) do
    status_tuple = Enum.find decoded_query_params, fn(params) ->
      if {@status_key, _status} = params, do: true
    end

    if status_tuple do
      {@status_key, expected_status} = status_tuple

      only_expected_status_list = Enum.filter(decoded_list, fn(item) ->
        Map.fetch!(item, @status_key) == expected_status
      end)

      first = List.first decoded_list
      first_status = Map.fetch! first, @status_key

      cond do
        length(decoded_list) > length(only_expected_status_list) ->
          only_expected_status_list

        first_status != expected_status ->
          []

        true -> false
      end
    else
      false
    end
  end
end
