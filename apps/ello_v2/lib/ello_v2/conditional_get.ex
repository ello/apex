defprotocol Ello.V2.ConditionalGet do
  @doc "Generate an etag for given data"
  def etag(data)
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
      length(category.promotionals)
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
    ]
    values
    |> :erlang.term_to_binary
    |> Ello.V2.ConditionalGet.etag
  end
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

  def gen_etag(post) do
    values = [
      :post,
      post.id,
      post.updated_at,
      post.loves_count,
      post.comments_count,
      post.reposts_count,
      post.author.updated_at
    ]
    values
    |> :erlang.term_to_binary
  end
end
