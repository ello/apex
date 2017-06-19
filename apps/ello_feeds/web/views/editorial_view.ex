defmodule Ello.Feeds.EditorialView do
  use Ello.Feeds.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  def webapp_url do
    "https://" <> Application.get_env(:ello_feeds, :webapp_host)
  end

  def title(editorial), do: editorial.content["title"]
  def description(editorial), do: editorial.content["subtitle"]

  def editorial_link(%{kind: "post", post: post}),
    do: webapp_url() <> post.author.username <> "/post/" <> post.token
  def editorial_link(%{kind: "internal"} = editorial),
    do: webapp_url() <> editorial.content["path"]
  def editorial_link(%{kind: "external"} = editorial),
    do: editorial.content["url"]

  # Not an actuall valid url, we are just using what the URL would be as a link.
  # We have sent "isPermalink=false" because it isn't a real uri.
  def guid(editorial) do
    webapp_url() <> "editorials/#{editorial.id}"
  end

  def image_url(%{one_by_one_image_struct: image}) do
    version = hdpi_version(image)
    image_url(image.path, version.filename)
  end

  def image_type(%{one_by_one_image_struct: image}) do
    version = hdpi_version(image)
    version.type
  end

  def image_length(%{one_by_one_image_struct: image}) do
    version = hdpi_version(image)
    version.size
  end

  defp hdpi_version(%{versions: versions}) do
    Enum.find(versions, &(&1.name == "hdpi"))
  end

  def categories(%{kind: "post", post: post}) do
    Enum.map(post.categories, &(&1.name))
  end
  def categories(_), do: []
end
