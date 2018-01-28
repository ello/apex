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
      resolve &Resolvers.Stream.user_stream/3
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

