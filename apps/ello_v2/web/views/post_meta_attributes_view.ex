defmodule Ello.V2.PostMetaAttributesView do
  use Ello.V2.Web, :view
  alias Ello.Core.Content.Post
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("post.json", %{post: post}) do
    %{
      description: description(post),
      images: images(post),
      embeds: embeds(post),
      robots: robots(post),
      title: post.seo_title,
      url: post_url(post),
      canonical_url: canonical_url(post),
    }
  end

  defp description(post) do
    post.body
    |> Enum.filter(&(&1["kind"] == "text"))
    |> Enum.map_join(" ", &(String.trim(&1["data"])))
    |> HtmlSanitizeEx.strip_tags
    |> String.trim
    |> case do
        ""   -> "Discover more amazing work like this on Ello."
        text -> text
    end
  end

  defp images(post) do
    Enum.map post.assets, fn(asset) ->
      version = Enum.find(asset.attachment_struct.versions, &(&1.name == "hdpi"))
      image_url(asset.attachment_struct.path, version.filename)
    end
  end

  defp embeds(post) do
    post.body
    |> Enum.filter(&(&1["kind"] == "embed"))
    |> Enum.map(&(&1["data"]["url"]))
    |> case do
      []   -> nil
      urls -> urls
    end
  end

  defp robots(%{author: %{bad_for_seo: true}}), do: "noindex, follow"
  defp robots(_), do: "index, follow"

  defp post_url(post) do
    "//#{webapp_host()}/#{post.author.username}/post/#{post.token}"
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end

  defp canonical_url(%{reposted_source: %Post{} = repost}) do
    post_url(repost)
  end
  defp canonical_url(_), do: nil
end
