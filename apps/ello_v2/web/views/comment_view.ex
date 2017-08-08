defmodule Ello.V2.CommentView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{
    UserView,
    AssetView,
    PostView,
  }

  def stale_checks(_, %{data: posts}) do
    [etag: etag(posts)]
  end

  @doc "Render a list of comments and relations"
  def render("index.json", %{data: comments} = opts) do
    users  = Enum.map(comments, &(&1.author))
    assets = Enum.flat_map(comments, &(&1.assets))
    parent = opts[:conn].assigns[:post]

    json_response()
    |> render_resource(:comments, comments, __MODULE__, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:assets, assets, AssetView, opts)
    |> include_linked(:parent_post, [parent], PostView, opts)
  end

  @doc "Render a single comment as included in other reponses"
  def render("comment.json", %{comment: comment} = opts) do
    render_self(comment, __MODULE__, opts)
  end

  def attributes, do: [
    :body,
    :created_at,
  ]

  def computed_attributes, do: [
    :summary,
    :content,
    :post_id,
    :author_id,
  ]

  def summary(%{rendered_summary: summary}, _), do: summary

  def content(%{rendered_content: content}, _), do: content

  def post_id(%{parent_post_id: id}, _), do: "#{id}"

  def author_id(%{author_id: id}, _), do: "#{id}"

  def links(comment, _conn) do
    %{
      author: %{
        id: "#{comment.author.id}",
        type: "users",
        href: "/api/v2/users/#{comment.author.id}",
      },
      assets: Enum.map(comment.assets, &("#{&1.id}")),
      parent_post: %{
        id:   "#{comment.parent_post_id}",
        type: "posts",
        href: "/api/v2/posts/#{comment.parent_post_id}",
      }
    }
  end
end
