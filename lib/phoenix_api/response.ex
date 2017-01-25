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

    # # ...
    # decoded_lists = fetch [], URI.to_string(uri), decoded_query_params

    # for item <- decoded_lists do
    #   status = Map.fetch! item, "status"
    #   IO.inspect status, label: "STATUS"
    # end
  end

  defmodule HeaderLink do
    def extract_from(nil), do: nil
    def extract_from(headers_link) do
      # headers_link = response.headers["link"]

      sanitized_headers_link = cond do
        is_binary(headers_link) -> [headers_link]
        is_list(headers_link) -> headers_link
        # nil -> nil
      end

      # IO.inspect [List.is_  headers_link], label: "\nWTFISTHIS"
      # sanitized_headers_link = headers_link |> String.split(",", trim: true)

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

      # result

      # cond do
      #   raw ->
      #     IO.inspect [List.is_  raw], label: "\nWTFISTHIS"
      #     link_strings = raw |> String.split(",", trim: true)

      #     next = "next"
      #     result = Enum.find_value(link_strings, fn(str) ->
      #       link = Regex.named_captures(
      #         ~r/<(?<url>[^>]+)>; \s* rel="(?<rel>[^"]*)"/x, str
      #       ) |> Enum.reduce(
      #         %{},
      #         fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
      #       )

      #       if !link, do: raise "No link match"

      #       valid_rel_values = [next, "prev"]
      #       if !Enum.member?(valid_rel_values, link.rel) do
      #         raise "'#{link.rel}' not a valid rel value... " <>
      #           "#{inspect valid_rel_values}"
      #       end

      #       if link.rel == "next" do
      #         link.url
      #       else
      #         nil
      #       end
      #     end)

      #     result
      #   true -> nil
      # end
    end
  end

  defp fetch(data, nil, _), do: data
  defp fetch(data, url, decoded_query_params)do
    Logger.debug "... before HTTP client get URL '#{url}'"
    response = HTTPotion.get(url) # <> "&page=200")
    Logger.debug "... after HTTP client get"

    next_url = HeaderLink.extract_from response.headers["link"]
    # next_url = HeaderLink.extract_from response

    if next_url, do: Process.sleep(3000 + :rand.uniform(2000))

    # ... DEBUG
    decoded_list = Poison.decode!(response.body)

    only_expected_status_list = status_bullcrap_api(
      decoded_list, decoded_query_params
    )

    if only_expected_status_list do
      fetch(data ++ only_expected_status_list, nil, decoded_query_params)
    else
      fetch(data ++ decoded_list, next_url, decoded_query_params)
    end

    # first = List.first decoded_list

    # status_key = "status"

    # if Map.fetch!(first, status_key) == "past"
    #   second = Enum.at decoded_list, 1
    #   if second do
    #     Map.fetch! second, status_key



    # for item <- decoded_list do
    #   status = Map.fetch! item, "status"
    #   IO.inspect status, label: "STATUS"
    # end

    # fetch(data ++ decoded_list, next_url, decoded_query_params)

    # # `Poison.decode!(response.body)` is the next "page" that we retrieved
    # fetch(data ++ Poison.decode!(response.body), next_url, decoded_query_params)
  end

  # Why all this? Because bullsh*t meetup.com API. If you're looking for status=past
  #   it does not stop even if you've gotten all the past status. You'll end up
  #   getting a "next" header link for upcoming meet ups even though the link
  #   itself has query status=past.
  # It seems it does stop at the boundary but better maker sure that this crap API
  #   doesn't spring any surprises.
  # events = [{status: past} same for all...]
  # Boundary, the events list above is cut off at number where past ends.
  # Next iter: events [{status: upcoming} ...]
  # What we ant to make sure is to fail if this happens.
  # events = [{status: past}, {status: upcoming}]
  @status_key "status"
  def status_bullcrap_api(decoded_list, decoded_query_params) do
    status_tuple = Enum.find decoded_query_params, fn(params) ->
      # {"status", status} = params
      if {@status_key, _status} = params, do: true
    end

    {@status_key, expected_status} = status_tuple

    if expected_status do
      first = List.first decoded_list
      first_status = Map.fetch! first, @status_key

      # not_the_same = Enum.find decoded_list, fn(item) ->
      #   IO.inspect Map.fetch!(item, @status_key), label: "STATUS"
      #   Map.fetch!(item, @status_key) != first_status
      # end

      # if not_the_same do
      #   raise(
      #     "Found item with different status as first item. \n" <>
      #     "First item: ID '#{first["id"]}', status '#{first_status}' \n" <>
      #     "Found item: IO '#{not_the_same["id"]}', " <>
      #       "status '#{not_the_same[@status_key]}'"
      #   )
      # end

      only_expected_status_list = Enum.filter(decoded_list, fn(item) ->
        IO.inspect [Map.fetch!(item, @status_key), expected_status], label: "STATUS"
        Map.fetch!(item, @status_key) == expected_status
      end)

      IO.inspect [length(decoded_list), length(only_expected_status_list)], label: "LENGTHS"
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

# defmodule PhoenixAPI.Response do
#   require Logger

#   def get(changes, query_key, decoded_query_params) do
#     query = Map.merge(%{
#       key: Application.fetch_env!(:phoenix_api, :secret) |> Keyword.fetch!(:key),
#       sign: true,
#       omit: "description,how_to_find_us",
#       page: 200
#     }, decoded_query_params |>
#       Enum.reduce(
#         %{}, fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
#       )
#     )

#     uri = %URI{}
#       |> Map.merge(%{
#         scheme: "https", host: "api.meetup.com", authority: "api.meetup.com"
#       })
#       |> Map.merge(%{path: changes.endpoint})
#       |> Map.merge(%{query_key => URI.encode_query(query) })

#     fetch [], URI.to_string(uri), changes
#   end

#   defmodule HeaderLink do
#     def extract_from(nil), do: nil
#     def extract_from(headers_link) do
#       # headers_link = response.headers["link"]

#       sanitized_headers_link = cond do
#         is_binary(headers_link) -> [headers_link]
#         is_list(headers_link) -> headers_link
#         # nil -> nil
#       end

#       # IO.inspect [List.is_  headers_link], label: "\nWTFISTHIS"
#       # sanitized_headers_link = headers_link |> String.split(",", trim: true)

#       next = "next"

#       Enum.find_value(sanitized_headers_link, fn(str) ->
#         link = Regex.named_captures(
#           ~r/<(?<url>[^>]+)>; \s* rel="(?<rel>[^"]*)"/x, str
#         ) |> Enum.reduce(
#           %{},
#           fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
#         )

#         if !link, do: raise "No link match"

#         valid_rel_values = [next, "prev"]
#         if !Enum.member?(valid_rel_values, link.rel) do
#           raise "'#{link.rel}' not a valid rel value... " <>
#             "#{inspect valid_rel_values}"
#         end

#         if link.rel == next, do: link.url, else: nil
#       end)

#       # result

#       # cond do
#       #   raw ->
#       #     IO.inspect [List.is_  raw], label: "\nWTFISTHIS"
#       #     link_strings = raw |> String.split(",", trim: true)

#       #     next = "next"
#       #     result = Enum.find_value(link_strings, fn(str) ->
#       #       link = Regex.named_captures(
#       #         ~r/<(?<url>[^>]+)>; \s* rel="(?<rel>[^"]*)"/x, str
#       #       ) |> Enum.reduce(
#       #         %{},
#       #         fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end
#       #       )

#       #       if !link, do: raise "No link match"

#       #       valid_rel_values = [next, "prev"]
#       #       if !Enum.member?(valid_rel_values, link.rel) do
#       #         raise "'#{link.rel}' not a valid rel value... " <>
#       #           "#{inspect valid_rel_values}"
#       #       end

#       #       if link.rel == "next" do
#       #         link.url
#       #       else
#       #         nil
#       #       end
#       #     end)

#       #     result
#       #   true -> nil
#       # end
#     end
#   end

#   defp fetch(data, nil, _), do: data
#   defp fetch(data, url, changes)do
#     Logger.debug "... before HTTP client get URL '#{url}'"
#     response = HTTPotion.get(url) # <> "&page=200")
#     Logger.debug "... after HTTP client get"

#     next_url = HeaderLink.extract_from response.headers["link"]
#     # next_url = HeaderLink.extract_from response

#     if next_url, do: Process.sleep(3000 + :rand.uniform(2000))

#     # `Poison.decode!(response.body)` is the next "page" that we retrieved
#     fetch(data ++ Poison.decode!(response.body), next_url, changes)
#   end
# end
