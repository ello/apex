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

    @desc "List of PageHeaders for the given page"
    field :page_headers, list_of(:page_header) do
      arg :kind, non_null(:page_header_kind), description: "What type of page headers to get"
      arg :slug, :string, description: "Optional slug to further specify which pageHeaders to get"
      resolve &Resolvers.PageHeaders.call/3
    end

    @desc "Stream of a user's posts"
    field :user_post_stream, :post_stream do
      resolve &Resolvers.UserPostStream.call/3
      arg :username, non_null(:string)
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 10
    end

    @desc "Returns a list of categories for the navbar"
    field :category_nav, list_of(:category) do
      resolve &Resolvers.UserCategories.call/3
    end

    @desc "Returns a list of all categories"
    field :all_categories, list_of(:category) do
      resolve &Resolvers.Categories.call/3
    end

    @desc "Stream of posts across the network"
    field :global_post_stream, :post_stream do
      arg :kind, non_null(:stream_kind), description: "Which variation of the stream to return"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
      resolve &Resolvers.GlobalPostStream.call/3
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
