defmodule Ello.V2.PostViewController do
  use Ello.V2.Web, :public_controller
  alias Ello.Events.TrackPostViews
  alias Ello.Core.{
    Network,
    Content,
  }

  def track(conn, params) do
    case find_posts(params) do
      nil -> okay(conn)
      []  -> okay(conn)
      posts ->
        TrackPostViews.track(conn, posts, tracking_options(params))
        okay(conn)
    end
  end

  defp okay(conn), do: send_resp(conn, 204, "")

  defp tracking_options(params) do
    %{
      stream_kind: safe_string(params["kind"]) || "email",
      stream_id: safe_string(params["id"]),
      user: find_user(params),
    }
  end

  defp find_user(%{"email" => email}), do: Network.load_view_tracking_user(%{email: email})
  defp find_user(%{"user_id" => id}), do: Network.load_view_tracking_user(%{id: id})
  defp find_user(_), do: nil

  @preloads %{
    author: %{},
    reposted_source: %{author: %{}},
  }

  defp find_posts(%{"posts" => tokens}),
    do: Content.posts(%{tokens: parse_list(tokens), preloads: @preloads, current_user: nil})
  defp find_posts(%{"post_tokens" => tokens}),
    do: Content.posts(%{tokens: parse_list(tokens), preloads: @preloads, current_user: nil})
  defp find_posts(%{"post_ids" => ids}),
  do: Content.posts(%{ids: to_ids(parse_list(ids)), preloads: @preloads, current_user: nil})
  defp find_posts(_), do: nil

  defp parse_list(list) when is_list(list), do: list
  defp parse_list(string) do
    string
    |> String.replace(~r{[\[\(\)\]]}, "")
    |> String.split(",")
  end

  defp to_ids([s | _] = ids) when is_binary(s), do: Enum.map(ids, &String.to_integer/1)
  defp to_ids(ids), do: ids

  defp safe_string(str) when is_binary(str),
    do: if String.valid?(str), do: str, else: nil
  defp safe_string(nil), do: nil
end
