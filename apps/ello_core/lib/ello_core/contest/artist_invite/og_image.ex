defmodule Ello.Core.Contest.ArtistInvite.OGImage do
  alias Ello.Core.{Image, Contest.ArtistInvite}

  @spec from_artist_invite(artist_invite :: ArtistInvite.t) :: Image.t
  def from_artist_invite(artist_invite) do
    %Image{
      filename: artist_invite.og_image,
      path:     "/uploads/artist_invite/og_image/#{artist_invite.id}",
      versions: Image.Version.from_metadata_with_defaults(%{
        metadata: artist_invite.og_image_metadata,
        original: artist_invite.og_image,
        required_versions: [:optimized],
        default_type: "image/jpeg",
      }),
    }
  end
end
