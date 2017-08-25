defmodule Ello.Serve.Webapp.EditorialView do
  use Ello.Serve.Web, :view
  import Ello.Serve.StandardParams
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Search.Post.Search
  alias Ello.Serve.Webapp.PostView
  alias Ello.Core.{Content, Discovery, Contest}

  def render("editorial.html", %{editorial: %{kind: "post"}} = assigns),
    do: render("post_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "internal"}} = assigns),
    do: render("internal_editorial.html", assigns)
  def render("editorial.html", %{editorial: %{kind: "external"}} = assigns),
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
    Search.post_search(standard_params(conn, %{
      trending:     true,
      within_days:  14,
      allow_nsfw:   false,
      images_only:  true,
      per_page:     5,
    })).results
  end

  def curated_posts(%{editorial: %{content: %{"post_tokens" => tokens}}, conn: conn}) do
    Content.posts(standard_params(conn, %{
      tokens: tokens
    }))
  end

  def category_posts(%{editorial: %{content: %{"slug" => slug}}, conn: conn}) do
    category = Discovery.category(standard_params(conn, %{
      id_or_slug: slug,
      images:     false,
    }))
    case category do
      nil -> []
      _ ->
        Search.post_search(standard_params(conn, %{
          trending:     true,
          within_days:  60,
          allow_nsfw:   false,
          images_only:  true,
          per_page:     5,
          category:     category.id,
        })).results
    end
  end

  def artist_invite_posts(%{editorial: %{content: %{"slug" => slug}}, conn: conn}) do
    invite = Contest.artist_invite(standard_params(conn, %{
      id_or_slug: "~#{slug}",
    }))
    case invite do
      nil -> []
      _ ->
        Enum.map(Contest.artist_invite_submissions(standard_params(conn, %{
          status:      "approved",
          images_only: true,
          per_page:    5,
          invite:      invite,
        })), &(&1.post))
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
