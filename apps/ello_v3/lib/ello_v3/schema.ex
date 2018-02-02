defmodule Ello.V3.Schema do
  use Absinthe.Schema
  alias Ello.V3.Resolvers
  alias Ello.V3.Middleware

  import_types Absinthe.Type.Custom
  import_types __MODULE__.ContentTypes
  import_types __MODULE__.DiscoveryTypes
  import_types __MODULE__.NetworkTypes
  import_types __MODULE__.AssetTypes
  import_types __MODULE__.ContestTypes

  query do
    @desc "Get a post by username and token"
    field :post, :post do
      arg :token,    non_null(:string)
      arg :username, non_null(:string), description: "Username post belongs to"
      resolve &Resolvers.FindPost.call/3
    end

    @desc "Stream of all posts on network"
    field :firehose_post_stream, :post_stream do
      resolve &Resolvers.Stream.firehose/3
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end

    @desc "Stream of a user's posts"
    field :user_post_stream, :post_stream do
      resolve &Resolvers.UserPostStream.call/3
      arg :username, non_null(:string)
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 10
    end

    @desc "Stream of posts by category"
    field :categories_post_stream, :post_stream do
      resolve &Resolvers.Stream.categories/3
      arg :categories, list_of(:id), description: "List of category ids to get posts stream for"
      arg :stream_type, non_null(:stream_type), description: "Type of stream to return, one of RECENT, FEATURED, or TRENDING"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end
  end

  @doc """
  Add our newrelic middleware into all top level queries.

  Allows us to track each different query as a seperate request for profiling in newrelic.
  """
  def middleware(middle, _field, %{identifier: :query}) do
    [Middleware.NewRelic, Middleware.StandardizeArguments | middle]
  end
  def middleware(middle, _field, _object), do: middle
end

