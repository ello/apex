defmodule Ello.Serve.Webapp.ArtistInviteShowView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Serve.Webapp.PostView

  def render("meta.html", %{artist_invite: artist_invite} = assigns) do
    assigns = assigns
              |> Map.put(:title, "#{artist_invite.meta_title} | Ello")
              |> Map.put(:description, artist_invite.meta_description)
              |> Map.put(:image, artist_invite_image_url(artist_invite))
              |> Map.put(:robots, "index, follow")
    render_template("meta.html", assigns)
  end

  def artist_invite_image_url(%{og_image_struct: %{path: path, versions: versions}}) do
    version = Enum.find(versions, &(&1.name == "optimized"))
    image_url(path, version.filename)
  end

  def next_artist_invite_submission_page_url(slug, submissions) do
    before = submissions
             |> List.last
             |> Map.get(:created_at)
             |> DateTime.to_iso8601
    webapp_url("invites/#{slug}", before: before)
  end
end
