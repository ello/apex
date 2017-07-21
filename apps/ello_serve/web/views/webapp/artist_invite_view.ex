defmodule Ello.Serve.Webapp.ArtistInviteView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  # TODO: Figure out content for meta tags for title, description, etc.
  def render("meta.html", assigns) do
    assigns = assigns
              |> Map.put(:title, "Artist Invites | Ello")
              |> Map.put(:description, "Artist Invites on Ello")
              |> Map.put(:robots, "index, follow")
    render_template("meta.html", assigns)
  end

  def artist_invite_image_url(%{logo_image_struct: %{path: path, versions: versions}}) do
    version = Enum.find(versions, &(&1.name == "hdpi"))
    image_url(path, version.filename)
  end

  def next_artist_invite_page_url(%{"page" => page}) do
    page = page
           |> String.to_integer
           |> (fn(n) -> n + 1 end).()
           |> Integer.to_string
    webapp_url("artist-invites", page: page)
  end
  def next_artist_invite_page_url(_),
    do: webapp_url("artist-invites", page: "2")
end
