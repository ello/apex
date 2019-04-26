defmodule TH.Dash.TalenthouseController do
  use TH.Dash.Web, :public_controller

  def login(conn, %{email: email, password: password, csrfToken: csrf_token}) do
    {:ok, response} = HTTPoison.post(
      talenthouse_url("/auth/email-login-post"),
      {:form, [email: email, password: password, csrfToken: csrf_token]},
      %{
        "Content-type" => "application/x-www-form-urlencoded"
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

  def statistics(conn, %{ inviteId: inviteId}) do
    {:ok, response} = HTTPoison.get(
      talenthouse_url("/invite-statistics/data?inviteId=" <> inviteId),
      [],
      hackney: [cookie: [""]]
    )
    conn
      |> json(%{
        body: response.body,
        })
  end

  defp sendCookieHeaderJson(conn, response) do
    cookie_header = response.headers
      |> Enum.find(fn
           {key, _} -> key == "set-cookie" || key == "Set-Cookie"
         end)
    cookie_value = case cookie_header do
      {_, value} -> value
      _ -> ""
    end

    conn
      |> json(%{
        cookie: cookie_value,
        body: response.body,
        })
  end

  defp talenthouse_url(url) do
    "https://www.talenthouse.com" <> url
  end
end
