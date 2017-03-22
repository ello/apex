defmodule Ello.V2.ClientProperties do
  use Plug.Builder

  plug :android
  plug :ios_version_from_header
  plug :ios_version_from_ua
  plug :ios
  plug :webapp
  plug :nudity
  plug :nsfw

  defp android(conn, _) do
    with [ua | _]  <- get_req_header(conn, "user_agent"),
         true      <- Regex.match?(~r/Ello Android/i, ua) do
      assign(conn, :android, true)
    else
      _ -> assign(conn, :android, false)
    end
  end

  defp ios_version_from_header(%{assigns: %{android: true}} = conn, _),
    do: conn
  defp ios_version_from_header(conn, _) do
    case get_req_header(conn, "x-ios-build-number") do
      [build | _] -> assign(conn, :ios_version, String.to_integer(build))
      _           -> conn
    end
  end

  defp ios_version_from_ua(%{assigns: %{ios_version: v}} = conn, _)
    when is_integer(v),
    do: conn
  defp ios_version_from_ua(%{assigns: %{android: true}} = conn, _),
    do: conn
  defp ios_version_from_ua(conn, _) do
    with [ua | _]   <- get_req_header(conn, "user_agent"),
         [_, build] <- Regex.run(~r[^Ello\/(\d{4,6}).*Darwin.*], ua) do
      assign(conn, :ios_version, String.to_integer(build))
    else
      _ -> conn
    end
  end

  defp ios(%{assigns: %{ios_version: v}} = conn, _) when is_integer(v),
    do: assign(conn, :ios, true)
  defp ios(conn, _),
    do: assign(conn, :ios, false)

  defp webapp(%{assigns: %{android: false, ios: false}} = conn, _),
    do: assign(conn, :webapp, true)
  defp webapp(conn, _),
    do: assign(conn, :webapp, false)

  defp nudity(%{assigns: %{allow_nudity: _preset}} = conn, _), do: conn
  defp nudity(%{assigns: %{current_user: %{settings: %{views_adult_content: true}}}} = conn, _),
    do: assign(conn, :allow_nudity, true)
  defp nudity(%{assigns: %{webapp: true}} = conn, _),
    do: assign(conn, :allow_nudity, true)
  defp nudity(conn, _),
    do: assign(conn, :allow_nudity, false)

  defp nsfw(%{assigns: %{allow_nsfw: _preset}} = conn, _), do: conn
  defp nsfw(%{assigns: %{current_user: %{settings: %{views_adult_content: allow_nsfw}}}} = conn, _),
    do: assign(conn, :allow_nsfw, allow_nsfw)
  defp nsfw(%{assigns: %{webapp: true}} = conn, _),
    do: assign(conn, :allow_nsfw, true)
  defp nsfw(conn, _),
    do: assign(conn, :allow_nsfw, false)
end
