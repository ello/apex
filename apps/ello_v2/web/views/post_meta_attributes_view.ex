defmodule Ello.V2.PostMetaAttributesView do
  use Ello.V2.Web, :view
  alias Ello.Core.Content.Post
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("post.json", %{post: post}) do
    %{
      description: Post.seo_description(post),
      images: images(post),
      embeds: embeds(post),
      robots: robots(post),
      title: post.seo_title,
      url: post_url(post),
      canonical_url: canonical_url(post),
    }
  end

  defp images(post) do
    post
    |> Post.ordered_assets
    |> Enum.map(&image_for_asset/1)
  end

  defp image_for_asset(%{attachment_struct: %{filename: orig, path: path, versions: versions}}) do
    version = if Regex.match?(~r(\.gif$), orig) do
      Enum.find(versions, &(&1.name == "optimized"))
    else
      Enum.find(versions, &(&1.name == "hdpi"))
    end
    image_url(path, version.filename)
  end

  defp embeds(post) do
    case Post.ordered_embed_urls(post) do
      []   -> nil
      urls -> urls
    end
  end

  defp robots(%{author: %{bad_for_seo?: true}}), do: "noindex, follow"
  defp robots(_), do: "index, follow"

  defp post_url(post) do
    "https://#{webapp_host()}/#{post.author.username}/post/#{post.token}"
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end

  defp canonical_url(%{reposted_source: %Post{} = repost}) do
    post_url(repost)
  end
  defp canonical_url(_), do: nil
end
