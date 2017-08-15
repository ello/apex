defmodule Ello.Serve.Webapp.ArtistInviteIndexView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("meta.html", assigns) do
    assigns = assigns
              |> Map.put(:title, "Artist Invites | Ello")
              |> Map.put(:description, "Submit your work, get published, and earn $$$.")
              |> Map.put(:robots, "index, follow")
    render_template("meta.html", assigns)
  end

  def artist_invite_image_url(%{og_image_struct: %{path: path, versions: versions}}) do
    version = Enum.find(versions, &(&1.name == "optimized"))
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
