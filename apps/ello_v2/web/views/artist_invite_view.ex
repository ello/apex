defmodule Ello.V2.ArtistInviteView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.UserView

  def stale_checks(_, %{data: artist_invites}) do
    [etag: etag(artist_invites)]
  end

  def render("index.json", %{data: artist_invites} = opts) do
    users = Enum.map(artist_invites, &(&1.brand_account))

    json_response()
    |> render_resource(:artist_invites, artist_invites, __MODULE__, opts)
    |> include_linked(:users, users, UserView, opts)
  end

  def render("artist_invite.json", %{artist_invite: artist_invite} = opts), do:
    render_self(artist_invite, __MODULE__, opts)
end
