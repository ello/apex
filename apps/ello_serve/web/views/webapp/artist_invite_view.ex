defmodule Ello.Serve.Webapp.ArtistInviteView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Serve.Webapp.PostView
  alias Ello.Core.Contest

  def render("meta.html", %{artist_invite: artist_invite} = assigns) do
    assigns = assigns
              |> Map.put(:title, "#{artist_invite.title} | Ello")
              |> Map.put(:description, artist_invite.raw_short_description)
              |> Map.put(:robots, "index, follow")
    render_template("meta.html", assigns)
  end
  def render("meta.html", assigns) do
    assigns = assigns
              |> Map.put(:title, "Artist Invites | Ello")
              |> Map.put(:description, "Artist Invites on Ello")
              |> Map.put(:robots, "index, follow")
    render_template("meta.html", assigns)
  end

  def render("noscript.html", %{artist_invite: %{status: "closed"} = invite} = assigns) do
    assigns = Map.put(assigns, :selections, selections(invite))
    render_template("noscript.html", assigns)
  end

  def artist_invite_image_url(%{header_image_struct: %{path: path, versions: versions}}) do
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

  def next_artist_invite_submission_page_url(id, submissions) do
    before = submissions
             |> List.last
             |> Map.get(:created_at)
             |> DateTime.to_iso8601
    webapp_url("artist-invites/#{id}", before: before)
  end

  defp selections(invite) do
    Contest.artist_invite_submissions(%{
      invite: invite,
      status: "selected",
      per_page: "25",
      before: nil,
    })
  end
end
