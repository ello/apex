
defmodule Ello.V3.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  enum :stream_type do
    value :recent
    value :featured
    value :trending
  end

  object :post_stream do
    field :next, :string
    field :per_page, :integer
    field :posts, list_of(:post)
  end

  object :post do
    field :id, :id
    field :token, :string
    field :calculated, :string, resolve: fn(_args, %{source: post}) ->
      {:ok, "#{post.id}-yolo"}
    end
    field :assets, list_of(:asset)
    field :author, :user
  end

  object :asset do
    field :id, :id
  end
end

defmodule Ello.V3.Schema.NetworkTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
  end
end

defmodule Ello.V3.Resolvers.Content do
  def find_post(parent, %{username: username, token: token}, resolver) do
    post = Ello.Core.Content.post(%{
      current_user: nil,
      id_or_token:  "~#{token}",
      allow_nsfw:   false,
      allow_nudity: true,
    })
    case post do
      %{author: %{username: ^username}} -> {:ok, post}
      _ -> {:error, "Post not found"}

    end
  end
end

defmodule Ello.V3.Resolvers.Stream do
  @firehose_key "all_post_firehose"
  def firehose(_, args, _) do
    stream = Ello.Stream.fetch(%{
      current_user: nil,
      before:       args[:before],
      keys:         [@firehose_key],
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
      allow_nudity: true,
    })

    {:ok, %{next: stream.before, posts: stream.posts}}
  end

  def user(_, %{username: username} = args, resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        posts = Ello.Core.Content.posts(%{
          user_id:      user.id,
          current_user: nil,
          before:       args[:before],
          per_page:     10,
          allow_nsfw:   false,
          allow_nudity: true,
        })
        {:ok, %{
          next: DateTime.to_iso8601(List.last(posts).created_at),
          posts: posts
        }}
      end
  end

  def categories(_, %{stream_type: _type}, _resolution) do
    {:ok, %{
      next: nil,
      posts: []
    }}
  end
end

defmodule Ello.V3.Schema do
  use Absinthe.Schema
  alias Ello.V3.Resolvers

  import_types __MODULE__.ContentTypes
  import_types __MODULE__.NetworkTypes

  query do

    @desc "Get a post by username and token"
    field :post, :post do
      arg :token,    non_null(:string)
      arg :username, non_null(:string), description: "Username post belongs to"
      resolve &Resolvers.Content.find_post/3
    end

    @desc "Stream of all posts on network"
    field :firehose_post_stream, :post_stream do
      resolve &Resolvers.Stream.firehose/3
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer
    end

    @desc "Stream of a user's posts"
    field :user_post_stream, :post_stream do
      resolve &Resolvers.Stream.user/3
      arg :username, non_null(:string)
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer
    end

    @desc "Stream of posts by category"
    field :categories_post_stream, :post_stream do
      resolve &Resolvers.Stream.categories/3
      arg :categories, list_of(:id), description: "List of category ids to get posts stream for"
      arg :stream_type, non_null(:stream_type), description: "Type of stream to return, one of RECENT, FEATURED, or TRENDING"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer
    end
  end
end

