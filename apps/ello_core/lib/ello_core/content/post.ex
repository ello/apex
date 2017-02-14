defmodule Ello.Core.Content.Post do
  use Ecto.Schema
  alias Ello.Core.Network.User
  alias Ello.Core.Content.{Love, Watch, Asset}
  alias __MODULE__.Block

  @type t :: %__MODULE__{}

  schema "posts" do
    field :token, :string
    field :seo_title, :string

    field :is_adult_content, :boolean
    field :is_disabled, :boolean
    field :has_nudity, :boolean
    field :is_saleable, :boolean

    field :mentioned_usernames, {:array, :string}, default: []
    field :category_ids, {:array, :integer}, default: []

    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    field :rendered_content, {:array, :map}
    field :rendered_summary, {:array, :map}

    belongs_to :author, User

    belongs_to :reposted_source, __MODULE__
    has_many :reposts, __MODULE__, foreign_key: :reposted_source_id

    belongs_to :parent_post, __MODULE__
    has_many :comments, __MODULE__, foreign_key: :parent_post_id

    field :body, {:array, :map}
    # embeds_many :body, Block

    has_many :assets, Asset

    # Current user placeholder state
    has_one :repost_from_current_user, __MODULE__, foreign_key: :reposted_source_id
    has_one :love_from_current_user, Love
    has_one :watch_from_current_user, Watch

    # Used to hold post counts retreived from Redis
    field :loves_count, :integer, virtual: true
    field :comments_count, :integer, virtual: true
    field :reposts_count, :integer, virtual: true
    field :views_count, :integer, virtual: true
  end

end
