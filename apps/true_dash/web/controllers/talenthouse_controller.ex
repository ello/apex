defmodule TH.TrueDash.TalenthouseController do
  use TH.TrueDash.Web, :public_controller
  alias NimbleCSV.RFC4180, as: CSV

  @timeout 15_000

  def login(conn, %{"cookie" => cookie, "email" => email, "password" => password, "csrfToken" => csrf_token}) do
    {:ok, response} = HTTPoison.post(
      talenthouse_url("/auth/email-login-post"),
      {:form, [email: email, password: password, csrfToken: csrf_token]},
      %{
        "Cookie" => cookie,
      }
    )

    conn
      |> sendCookieHeaderJson(response)
  end

  def login(conn, _) do
    {:ok, response} = HTTPoison.get(
      talenthouse_url("/login"),
      [{"Accept", "text/html"}]
    )

    conn
      |> sendCookieHeaderJson(response)
  end

  def browse(conn, %{"cookie" => cookie} = params) do
    page = Map.get(params, "page", "1")
    {:ok, response} = HTTPoison.get(
      talenthouse_url("/collaborate/all/ajax/" <> page),
      [],
      hackney: [cookie: [cookie]]
    )

    regex_matches = Regex.scan(~r{\bhref="(/i/(?:[^"]*))"}, response.body)
    invites = regex_matches
    |> Enum.flat_map(fn
        [_, link | _] -> [link]
        _ -> nil
      end)
    |> Enum.uniq
    |> Enum.map(&(Task.async(fn ->
        invite_title_via_url(cookie, &1)
      end)))
    |> Enum.map(fn(task) ->
      Task.await(task, @timeout)
      end)

    conn
    |> json(%{invites: invites})
  end

  def delete_statistics(conn, %{"cookie" => cookie}) do
    HTTPoison.delete(
      talenthouse_url("/invite-statistics/data"),
      [],
      hackney: [cookie: [cookie]]
    )
    conn
      |> json(["ok"])
  end

  def statistics(conn, %{"cookie" => cookie, "id" => invite_id, "url" => url}) do
    stats = invite_stats_json_via_id(cookie, url, invite_id)

    conn
    |> json(stats)
  end

  defp invite_title_via_url(cookie, url) do
    url = url |> String.replace_suffix("/submissions", "")

    {:ok, invite_response} = HTTPoison.get(
      talenthouse_url(url),
      [],
      hackney: [cookie: [cookie]]
    )

    [_, invite_id] = Regex.run(~r[\bTalenthouse.Participate.inviteId = (\d+)], invite_response.body)
    [_, title] = Regex.run(~r[<title>(.*)</title>], invite_response.body)
    title = HtmlEntities.decode(title)

    %{}
      |> Map.put(:inviteId, invite_id)
      |> Map.put(:title, title)
      |> Map.put(:url, url)
  end

  def invite_stats_json_via_id(cookie, url, invite_id) do
    stats_task = start_stats_task(cookie, invite_id)
    csv_task = start_csv_task(cookie, url)

    {:ok, stats_response} = Task.await(stats_task, @timeout)
    {:ok, csv_response} = Task.await(csv_task, @timeout)

    json_body = parse_stats_response(stats_response)
    csv = parse_csv_response(csv_response)

    countries = parse_csv_countries(csv)
    {total, female, male, unspecified} = parse_csv_submissions(csv)
    {percent_female, percent_male, percent_unspecified} = if total > 0 do
      {female / total, male / total, unspecified / total}
    else
      {0, 0, 0}
    end

    json_body
      |> Map.put(:inviteId, invite_id)
      |> Map.put(:submissions, %{totals: %{total: total, female: female, male: male, unspecified: unspecified}, percent: %{female: percent_female, male: percent_male, unspecified: percent_unspecified}})
      |> Map.put(:countries, countries)
  end

  defp parse_stats_response(stats_response) do
    {:ok, json_body} = case stats_response.body do
      "" -> {:ok, %{}}
      body -> Jason.decode(body)
    end

    json_body
  end


  defp parse_csv_response(csv_response) do
    try do
      CSV.parse_string(csv_response.body)
    rescue NimbleCSV.ParseError ->
      nil
    end
  end

  defp parse_csv_submissions(csv) do
    csv
    |> Enum.reduce({0, 0, 0, 0}, fn(row, {total, female, male, unspecified}) ->
      gender = row |> Enum.at(8, "")
      case gender do
        "female" -> {total + 1, female + 1, male, unspecified}
        "male"   -> {total + 1, female, male + 1, unspecified}
        _        -> {total + 1, female, male, unspecified + 1}
      end
    end)
  end

  defp parse_csv_countries(csv) do
    csv
    |> Enum.reduce(%{}, fn(row, accum) ->
      country = row |> Enum.at(6, "")
      Map.put(accum, country, Map.get(accum, country, 0) + 1)
    end)
    |> Map.to_list
    |> Enum.sort_by(fn({_, count}) ->
      -count
    end)
    |> Enum.slice(0, 10)
    |> Enum.map(fn({country, count}) ->
      %{country: country, count: count}
    end)
  end

  defp start_stats_task(cookie, invite_id) do
    Task.async(fn -> HTTPoison.get(
          talenthouse_url("/invite-statistics/data?inviteId=" <> invite_id),
          [],
          recv_timeout: @timeout,
          hackney: [cookie: [cookie]]
        )end)
  end

  defp start_csv_task(cookie, url) do
    Task.async(fn -> HTTPoison.get(
          talenthouse_url(url <> "/participants/export"),
          [],
          recv_timeout: @timeout,
          hackney: [cookie: [cookie]]
        )end)
  end

  defp sendCookieHeaderJson(conn, response) do
    cookie_value = response.headers
      |> Enum.find(fn
           {key, _} -> key == "set-cookie" || key == "Set-Cookie"
         end)
      |> (fn
      {_, value} -> value
      _ -> ""
    end).()

    [_, csrf] = Regex.run(~r[<input type="hidden" name="csrfToken" value="(.*?)"], response.body)

    conn
      |> json(%{
        cookie: cookie_value,
        csrf: csrf,
      })
  end

  defp talenthouse_url(url) do
    "https://www.talenthouse.com" <> url
  end
end
