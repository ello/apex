defmodule Ello.V2.ArtistInviteView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{UserView, ImageView}

  def stale_checks(_, %{data: artist_invites}) do
    [etag: etag(artist_invites)]
  end

  def render("index.json", %{data: artist_invites} = opts) do
    users = Enum.map(artist_invites, &(&1.brand_account))

    json_response()
    |> render_resource(:artist_invites, artist_invites, __MODULE__, opts)
    |> include_linked(:users, users, UserView, opts)
  end

  def render("show.json", %{data: artist_invite} = opts) do
    json_response()
    |> render_resource(:artist_invites, artist_invite, __MODULE__, opts)
    |> include_linked(:users, artist_invite.brand_account, UserView, opts)
  end

  def render("artist_invite.json", %{artist_invite: artist_invite} = opts), do:
    render_self(artist_invite, __MODULE__, opts)

  def attributes, do: [
    :title,
    :slug,
    :invite_type,
    :opened_at,
    :closed_at,
    :status,
    :submission_body_block,
  ]

  def computed_attributes, do: [
    :header_image,
    :logo_image,
    :description,
    :short_description,
    :guide,
  ]

  def header_image(artist_invite, conn),
    do: render(ImageView, "image.json", conn: conn, image: artist_invite.header_image_struct)

  def logo_image(artist_invite, conn),
    do: render(ImageView, "image.json", conn: conn, image: artist_invite.logo_image_struct)

  def description(artist_invite, _),
    do: artist_invite.rendered_description

  def short_description(artist_invite, _),
    do: artist_invite.rendered_short_description

  def guide(artist_invite, _), do: artist_invite.guide
end
