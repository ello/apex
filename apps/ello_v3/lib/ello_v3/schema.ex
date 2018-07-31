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
  import_types __MODULE__.NotificationTypes

  query do
    @desc "Get a post by username and token"
    field :post, :post do
      resolve &Resolvers.FindPost.call/3
      arg :id, :id
      arg :token, :string
      arg :username, :string, description: "Username post belongs to"
    end

    @desc "Get posts by token"
    field :find_posts, list_of(:post) do
      resolve &Resolvers.FindPosts.call/3
      arg :tokens, list_of(:string)
    end

    @desc "List of PageHeaders for the given page"
    field :page_headers, list_of(:page_header) do
      resolve &Resolvers.PageHeaders.call/3
      arg :kind, non_null(:page_header_kind), description: "What type of page headers to get"
      arg :slug, :string, description: "Optional slug to further specify which pageHeaders to get"
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

    @desc "Returns a list of all active categories"
    field :all_categories, list_of(:category) do
      resolve &Resolvers.Categories.call/3
    end

    @desc "Returns a list of filtered active categories"
    field :search_categories, :category_search_result do
      resolve &Resolvers.SearchCategories.call/3
      arg :query, :string, description: "Search categories by name"
      arg :administered, :boolean, description: "Restrict categories to categories the current user moderates or curates."
      arg :per_page, :integer, default_value: 20
    end

    @desc "Returns a single (active) category"
    field :category, :category do
      resolve &Resolvers.Category.call/3
      arg :slug, non_null(:string)
    end

    @desc "Stream of posts across the network"
    field :global_post_stream, :post_stream do
      resolve &Resolvers.GlobalPostStream.call/3
      arg :kind, non_null(:stream_kind), description: "Which variation of the stream to return"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end

    @desc "Aggregate post streams from all subscribed categories"
    field :subscribed_post_stream, :post_stream do
      resolve &Resolvers.SubscribedPostStream.call/3
      arg :kind, non_null(:stream_kind), description: "Which variation of the stream to return"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end

    @desc "Aggregate post streams from all followed users"
    field :following_post_stream, :post_stream do
      middleware Middleware.RequireCurrentUser
      resolve &Resolvers.FollowingPostStream.call/3
      arg :kind, non_null(:stream_kind), description: "Which variation of the stream to return"
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end

    @desc "Is there any new content since the provided datetime."
    field :new_following_post_stream_content, :new_content do
      middleware Middleware.RequireCurrentUser
      resolve &Resolvers.FollowingPostStream.new_content/3
      arg :kind, :stream_kind, default_value: :recent
      arg :since, :datetime
    end

    @desc "Stream of a category's posts"
    field :category_post_stream, :post_stream do
      resolve &Resolvers.CategoryPostStream.call/3
      arg :kind, non_null(:stream_kind), description: "Which variation of the stream to return"
      arg :id, :integer
      arg :slug, :string
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 10
    end

    @desc "Stream of editorials"
    field :editorial_stream, :editorial_stream do
      resolve &Resolvers.EditorialStream.call/3
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
      arg :preview, :boolean, default_value: false, description: "Preview unpublished editorials - only works on staff accounts"
    end

    @desc "Find a single user by id or username"
    field :find_user, :user do
      resolve &Resolvers.FindUser.call/3
      arg :username, :string, description: "Find user by username"
      arg :id, :id, description: "Find user by id"
    end

    @desc "Returns a list of comments"
    field :comment_stream, :comment_stream do
      resolve &Resolvers.CommentStream.call/3
      arg :id, :id
      arg :token, :string
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 25
    end

    @desc "Stream of a user's loves"
    field :user_love_stream, :love_stream do
      resolve &Resolvers.UserLoveStream.call/3
      arg :username, non_null(:string)
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 10
    end

    @desc "Stream of a user's notifications"
    field :notification_stream, :notification_stream do
      middleware Middleware.RequireCurrentUser
      resolve &Resolvers.NotificationStream.call/3
      arg :before, :string, description: "Pagination cursor, returned by previous page"
      arg :per_page, :integer, default_value: 10
      arg :category, :notification_category, default_value: :all
    end

    @desc "Is there any new content since the provided datetime."
    field :new_notification_stream_content, :new_content do
      middleware Middleware.RequireCurrentUser
      resolve &Resolvers.NotificationStream.new_content/3
    end

    @desc "Search users"
    field :search_users, :user_stream do
      resolve &Resolvers.SearchUsers.call/3
      arg :query, :string
      arg :username, :boolean, default_value: true, description: "Search by username only"
      arg :per_page, :integer, default_value: 10
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
