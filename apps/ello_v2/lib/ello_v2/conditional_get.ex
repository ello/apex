defprotocol Ello.V2.ConditionalGet do
  @doc "Generate an etag for given data"
  def etag(data)
end

defimpl Ello.V2.ConditionalGet, for: Atom do
  def etag(nil), do: ""
end

defimpl Ello.V2.ConditionalGet, for: BitString do
  def etag(binary) do
    "W/" <> Base.encode16(:crypto.hash(:md5, binary), case: :lower)
  end
end

defimpl Ello.V2.ConditionalGet, for: List do
  def etag(list) do
    list
    |> Enum.map(&Ello.V2.ConditionalGet.etag/1)
    |> Enum.join("-")
    |> Ello.V2.ConditionalGet.etag
  end
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Discovery.Category do
  def etag(category) do
    values = [
      :category,
      category.id,
      category.updated_at,
      Ello.V2.ConditionalGet.etag(category.promotionals),
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Discovery.Promotional do
  def etag(promo) do
    values = [
      :promotional,
      promo.id,
      promo.updated_at,
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Network.User do
  def etag(user) do
    values = [
      :user,
      user.id,
      user.updated_at,
      user.posts_count,
      user.loves_count,
      user.followers_count,
      user.following_count,
      relationship(user.relationship_to_current_user)
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end

  defp relationship(%Ello.Core.Network.Relationship{} = relationship) do
    relationship.priority
  end
  defp relationship(_), do: "nil"
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Content.Post do
  def etag(%{reposted_source: %Ello.Core.Content.Post{} = reposted} = post) do
    [gen_etag(reposted), gen_etag(post)]
    |> Enum.join("")
    |> Ello.V2.ConditionalGet.etag
  end

  def etag(not_repost) do
    not_repost
    |> gen_etag
    |> Ello.V2.ConditionalGet.etag
  end

  defp gen_etag(post) do
    values = [
      :post,
      post.id,
      post.updated_at,
      post.loves_count,
      post.comments_count,
      post.reposts_count,
      categories(post),
      Ello.V2.ConditionalGet.etag(post.author),
    ]
    values
    |> :erlang.term_to_binary
  end

  defp categories(%{categories: []}), do: ""
  defp categories(%{categories: categories}) when is_list(categories) do
    categories
    |> Enum.map(&(&1.updated_at))
    |> Enum.join("")
  end
  defp categories(%{categories: _}), do: ""
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Discovery.Editorial do
  def etag(editorial) do
    values = [
      :editorial,
      editorial.id,
      editorial.updated_at,
      Ello.V2.ConditionalGet.etag(editorial.post),
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Contest.ArtistInvite do
  def etag(artist_invite) do
    values = [
      :artist_invite,
      artist_invite.id,
      artist_invite.updated_at,
      Ello.Core.Contest.ArtistInvite.status(artist_invite),
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
end

defimpl Ello.V2.ConditionalGet, for: Ello.Core.Contest.ArtistInviteSubmission do
  def etag(submision) do
    values = [
      :artist_invite_submission,
      submision.id,
      submision.updated_at,
      Ello.V2.ConditionalGet.etag(submision.post),
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
end
