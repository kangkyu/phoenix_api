defmodule PhoenixAPI.Response do
  def get(changes, query_key, decoded_query_params) do
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
      |> Map.merge(%{path: changes.endpoint})
      |> Map.merge(%{query_key => URI.encode_query(query) })

    fetch [], URI.to_string(uri), changes
  end

  defmodule HeaderLink do
    def extract_from(response) do
      raw = response.headers["link"]

      cond do
        raw ->
          link_strings = raw |> String.split(",", trim: true)

          next = "next"
          result = Enum.find_value(link_strings, fn(str) ->
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

            if link.rel == "next" do
              link.url
            else
              nil
            end
          end)

          result
        true -> nil
      end
    end
  end

  defp fetch(data, nil, _), do: data
  defp fetch(data, url, changes)do
    response = HTTPotion.get url
    next_url = HeaderLink.extract_from response
    if next_url, do: Process.sleep(3000 + :rand.uniform(2000))

    # `Poison.decode!(response.body)` is the next "page" that we retrieved
    fetch(data ++ Poison.decode!(response.body), next_url, changes)
  end
end
