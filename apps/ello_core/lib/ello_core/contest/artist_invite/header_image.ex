defmodule Ello.Core.Contest.ArtistInvite.HeaderImage do
  alias Ello.Core.{Image, Contest.ArtistInvite}

  @spec from_artist_invite(artist_invite :: ArtistInvite.t) :: Image.t
  def from_artist_invite(artist_invite) do
    %Image{
      filename: artist_invite.header_image,
      path:     "/uploads/artist_invite/header_image/#{artist_invite.id}",
      versions: Image.Version.from_metadata_with_defaults(%{
        metadata: artist_invite.header_image_metadata,
        original: artist_invite.header_image,
        required_versions: [:optimized, :xhdpi, :hdpi],
        default_type: "image/jpeg",
      }),
    }
  end
end
