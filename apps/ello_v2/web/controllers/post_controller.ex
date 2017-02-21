defmodule Ello.V2.PostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.{Content, Content.Post}
  alias Ello.Events
  alias Ello.Events.CountPostView

  def show(conn, params) do
    with %Post{} = post <- load_post(conn, params),
         true           <- owned_by_user(post, params) do
      track_post_view(conn, post)
      render(conn, post: post)
    else
      _ -> send_resp(conn, 404, "")
    end
  end

  defp load_post(conn, %{"id" => id_or_slug}) do
    Content.post(id_or_slug,
      conn.assigns[:current_user],
      conn.assigns[:allow_nsfw],
      conn.assigns[:allow_nudity]
    )
  end

  defp track_post_view(%{assigns: assigns}, post) do
    current_user_id = case assigns[:current_user] do
      %{id: id} -> id
      _ -> nil
    end

    event = %CountPostView{
      post_ids: [post.id],
      current_user_id: current_user_id,
      stream_kind: "post",
    }
    Events.publish(event)
  end

  defp owned_by_user(post, %{"user_id" => "~" <> username}),
    do: post.author.username == username
  defp owned_by_user(post, %{"user_id" => user_id}),
    do: "#{post.author.id}" == user_id
  defp owned_by_user(_, _), do: true

end
