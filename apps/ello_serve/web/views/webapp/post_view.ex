defmodule Ello.Serve.Webapp.PostView do
  use Ello.Serve.Web, :view
  alias Ello.Core.Content.Post
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("block.html", %{block: %{"kind" => "image"}} = assigns),
    do: render("image_block.html", assigns)

  def render("block.html", %{block: %{"kind" => "text"}} = assigns),
    do: render("html_block.html", assigns)

  def render("meta.html", %{post: post} = assigns) do
    assigns = assigns
              |> Map.put(:title, post.seo_title)
              |> Map.put(:description, Post.seo_description(post))
              |> Map.put(:image, false)
              |> Map.put(:robots, robots(post))
              |> Map.put(:twitter_card, twitter_card(post))
    render_template("meta.html", assigns)
  end

  def image_urls(post) do
    post
    |> Post.ordered_assets
    |> Enum.map(&image_for_asset/1)
  end

  def embed_urls(post),
    do: Post.ordered_embed_urls(post)

  def post_url(post) do
    webapp_url("#{post.author.username}/post/#{post.token}")
  end

  def repost?(%{reposted_source: %{}}), do: true
  def repost?(_), do: false

  def summary(%{reposted_source: %{rendered_summary: summary}}), do: summary
  def summary(%{rendered_summary: post_summary}), do: post_summary

  def loves_count(%{reposted_source: %{loves_count: count}}), do: count
  def loves_count(%{loves_count: count}), do: count

  def comments_count(%{reposted_source: %{comments_count: count}}), do: count
  def comments_count(%{comments_count: count}), do: count

  def reposts_count(%{reposted_source: %{reposts_count: count}}), do: count
  def reposts_count(%{reposts_count: count}), do: count

  def views_count(%{reposted_source: %{views_count: count}}), do: count
  def views_count(%{views_count: count}), do: count

  defp robots(%{author: %{bad_for_seo?: true}}), do: "noindex, follow"
  defp robots(_), do: "index, follow"

  # TODO: Copied from post meta attributes serializer.
  defp image_for_asset(%{attachment_struct: %{filename: orig, path: path, versions: versions}}) do
    version = if Regex.match?(~r(\.gif$), orig) do
      Enum.find(versions, &(&1.name == "optimized"))
    else
      Enum.find(versions, &(&1.name == "hdpi"))
    end
    image_url(path, version.filename)
  end

  def block_image_url(%{block: block, post: post}) do
    case Enum.find(post.assets, &("#{&1.id}" == block["links"]["assets"])) do
      nil   -> block["data"]["url"]
      asset -> image_for_asset(asset)
    end
  end

  defp twitter_card(%{assets: [], reposted_source: %{assets: []}}), do: "summary"
  defp twitter_card(%{assets: []}), do: "summary"
  defp twitter_card(_), do: "summary_large_image"
end
