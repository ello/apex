defmodule Ello.Serve.Webapp.EditorialView do
  use Ello.Serve.Web, :view
  import Ello.Serve.StandardParams
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Search.Post.Search
  alias Ello.Serve.Webapp.PostView
  alias Ello.Core.{Content, Discovery, Contest}
  import Ello.Events.TrackPostViews, only: [track: 3]

  def render("editorial.html", %{editorial: %{kind: "post"}} = assigns),
    do: render("post_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "internal"}} = assigns),
    do: render("internal_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "external"}} = assigns),
    do: render("external_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "sponsored"}} = assigns),
    do: render("external_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "category"}} = assigns),
    do: render("category_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "artist_invite"}} = assigns),
    do: render("artist_invite_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "curated_posts"}} = assigns),
    do: render("curated_posts_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "following"}} = assigns),
    do: render("following_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "invite_join"}} = assigns),
    do: render("invite_join_editorial.html", assigns)

  def trending_posts(%{conn: conn}) do
    conn
    |> standard_params(%{
      trending:     true,
      within_days:  14,
      allow_nsfw:   false,
      images_only:  true,
      per_page:     5,
    })
    |> Search.post_search
    |> Map.get(:results)
    |> track(conn, stream_kind: "trending_editorial")
  end

  def curated_posts(%{editorial: %{content: %{"post_tokens" => tokens}}, conn: conn}) do
    conn
    |> standard_params(%{tokens: tokens})
    |> Content.posts
    |> track(conn, stream_kind: "curated_posts_editorial")
  end

  def category_posts(%{editorial: %{content: %{"slug" => slug}}, conn: conn}) do
    category = Discovery.category(standard_params(conn, %{
      id_or_slug: slug,
      images:     false,
    }))
    case category do
      nil -> []
      _ ->
        conn
        |> standard_params(%{
          trending:     true,
          within_days:  60,
          allow_nsfw:   false,
          images_only:  true,
          per_page:     5,
          category_ids: [category.id],
        })
        |> Search.post_search
        |> Map.get(:results)
        |> track(conn, stream_kind: "category_trending_editorial", stream_id: category.id)
    end
  end

  def artist_invite_posts(%{editorial: %{content: %{"slug" => slug}}, conn: conn}) do
    invite = Contest.artist_invite(standard_params(conn, %{
      id_or_slug: "~#{slug}",
    }))
    case invite do
      nil -> []
      _ ->
        conn
        |> standard_params(%{status: "approved", images_only: true, per_page: 5, invite: invite})
        |> Contest.artist_invite_submissions
        |> Enum.map(&(&1.post))
        |> track(conn, stream_kind: "artist_invite_submissions_editorial", stream_id: invite.id)
    end
  end

  def post_url(post) do
    webapp_url("#{post.author.username}/post/#{post.token}")
  end

  def title(%{content: %{"title" => title}}), do: title

  def subtitle(%{content: %{"rendered_subtitle" => subtitle}}), do: subtitle

  def external_url(%{content: %{"url" => url}}), do: url
  def internal_url(%{content: %{"path" => path}}), do: webapp_url(path)

  def editorial_image_url(%{one_by_one_image_struct: %{filename: orig, path: path, versions: versions}}) do
    version = if Regex.match?(~r(\.gif$), orig) do
      Enum.find(versions, &(&1.name == "original"))
    else
      Enum.find(versions, &(&1.name == "hdpi"))
    end
    if version do
      image_url(path, version.filename)
    else
      ""
    end
  end
  def editorial_image_url(_), do: ""

  def post_image_url(post) do
    block = Enum.find(post.rendered_content, &(&1["kind"] == "image"))
    PostView.block_image_url(%{block: block, post: post})
  end

  def more_editorials?(%{editorials: []}), do: false
  def more_editorials?(%{editorials: _}), do: true

  def next_page_url(%{editorials: editorials}) do
    last_editorial = List.last(editorials)
    webapp_url("", %{before: last_editorial.published_position})
  end
end
