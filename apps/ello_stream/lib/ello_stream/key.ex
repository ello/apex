defmodule Ello.Stream.Key do
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Contest.ArtistInvite

  @category_key "categories:v1"
  @artist_invite_key "artist_invite:v1"

  def find(:global_recent), do: "all_post_firehose"
  def find(:global_shop), do: "global_shop_stream:v1"
  def find(%ArtistInvite{id: id}), do: "#{@artist_invite_key}:#{id}"

  def find(%ArtistInvite{id: id}, _), do: "#{@artist_invite_key}:#{id}"
  def find(%Category{roshi_slug: slug}, :featured), do: "#{@category_key}:#{slug}"
  def find(%Category{roshi_slug: slug}, :recent), do: "#{@category_key}:recent:#{slug}"
  def find(%Category{roshi_slug: slug}, :shop), do: "#{@category_key}:shop:#{slug}"
end
