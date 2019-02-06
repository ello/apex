defmodule Ello.Feeds.EditorialView do
  use Ello.Feeds.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  def webapp_url(path \\ "") do
    %URI{
      host:      Application.get_env(:ello_feeds, :webapp_host),
      authority: Application.get_env(:ello_feeds, :webapp_host),
      scheme:    "https",
    } |> URI.merge(path)
  end

  def title(editorial), do: editorial.content["title"]
  def description(editorial), do: editorial.content["subtitle"]

  def editorial_link(%{kind: "post", post: post}),
    do: webapp_url(post.author.username <> "/post/" <> post.token)
  def editorial_link(%{kind: "internal"} = editorial),
    do: webapp_url(editorial.content["path"])
  def editorial_link(%{kind: "external"} = editorial),
    do: editorial.content["url"]
  def editorial_link(%{kind: "sponsored"} = editorial),
    do: editorial.content["url"]

  # Not an actuall valid url, we are just using what the URL would be as a link.
  # We have sent "isPermalink=false" because it isn't a real uri.
  def guid(editorial) do
    webapp_url("editorials/#{editorial.id}")
  end

  def image_url(%{one_by_one_image_struct: image}) do
    case fetch_version(image) do
      %{filename: filename} -> image_url(image.path, filename)
      _ -> ""
    end
  end

  def image_type(%{one_by_one_image_struct: image}) do
    case fetch_version(image) do
      %{type: type} -> type
      _ -> ""
    end
  end

  def image_length(%{one_by_one_image_struct: image}) do
    case fetch_version(image) do
      %{size: size} -> size
      _ -> ""
    end
  end

  defp fetch_version(%{versions: versions}) do
    Enum.find(versions, &(&1.name == "xhdpi"))
  end

  defp fetch_version(_) do
    nil
  end

  def categories(%{kind: "post", post: post}) do
    Enum.map(post.categories, &(&1.name))
  end
  def categories(_), do: []
end
