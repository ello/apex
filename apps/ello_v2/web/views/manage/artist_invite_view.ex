defmodule Ello.V2.Manage.ArtistInviteView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{ImageView}
  alias Ello.Core.Contest.{ArtistInvite}

  def render("index.json", %{data: artist_invites} = opts) do
    json_response()
    |> render_resource(:artist_invites, artist_invites, __MODULE__, opts)
  end

  def render("show.json", %{data: artist_invite} = opts) do
    json_response()
    |> render_resource(:artist_invites, artist_invite, __MODULE__, opts)
  end

  def render("artist_invite.json", %{artist_invite: artist_invite} = opts), do:
    render_self(artist_invite, __MODULE__, opts)

  def attributes, do: [
    :title,
    :slug,
    :invite_type,
    :opened_at,
    :closed_at,
    :custom_stats,
  ]

  def computed_attributes, do: [
    :header_image,
    :status,
  ]

  def header_image(artist_invite, conn),
    do: render(ImageView, "image.json", conn: conn, image: artist_invite.header_image_struct)

  def status(invite, _), do: ArtistInvite.status(invite)
end
