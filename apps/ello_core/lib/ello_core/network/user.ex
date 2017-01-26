defmodule Ello.Core.Network.User do
  use Ecto.Schema
  alias Ello.Core.Redis
  alias Ello.Core.Network.{Relationship, User}

  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string
    field :email_hash, :string
    field :username, :string
    field :name, :string
    field :short_bio, :string
    field :formatted_short_bio, :string
    field :links, :string
    field :location, :string
    field :location_lat, :float
    field :location_long, :float

    field :avatar, :string
    field :avatar_metadata, :map
    field :cover_image, :string
    field :cover_image_metadata, :map
    field :background_position, :string

    field :is_system_user, :boolean, default: false
    field :is_public, :boolean, default: true
    field :bad_for_seo?, :boolean, default: true
    field :category_ids, {:array, :integer}, default: []
    field :categories, {:array, :map}, default: [], virtual: true

    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    embeds_one :settings, User.Settings
    has_many :relationships, Relationship, foreign_key: :owner_id
    has_many :inverse_relationships, Relationship, foreign_key: :subject_id

    # Used to eager load user's relationship to current user.
    has_one :relationship_to_current_user, Relationship, foreign_key: :subject_id

    # Used to hold user counts retreived from Redis
    field :loves_count, :integer, virtual: true
    field :posts_count, :integer, virtual: true
    field :following_count, :integer, virtual: true
    field :followers_count, :integer, virtual: true

    # Used to hold blocked ids retreived from Redis
    field :inverse_blocked_ids, {:array, :integer}, default: [], virtual: true
    field :blocked_ids, {:array, :integer}, default: [], virtual: true
    field :all_blocked_ids, {:array, :integer}, default: [], virtual: true
  end

  @doc """
  Load blocked and inverse blocked ids.

  Typically used on current user to ensure no blocked users/posts are returned.
  """
  @spec preload_blocked_ids(user :: t) :: t
  def preload_blocked_ids(%__MODULE__{id: nil} = user), do: user
  def preload_blocked_ids(%__MODULE__{} = user) do
    user = user
           |> Map.put(:inverse_blocked_ids, inverse_blocked_ids(user))
           |> Map.put(:blocked_ids, blocked_ids(user))

    Map.put(user, :all_blocked_ids, user.inverse_blocked_ids ++ user.blocked_ids)
  end

  defp blocked_ids(%__MODULE__{id: id}) do
    {:ok, ids} = Redis.command(["SMEMBERS", "user:#{id}:block_id_cache"])
    Enum.map(ids, &String.to_integer/1)
  end

  defp inverse_blocked_ids(%__MODULE__{id: id}) do
    {:ok, ids} = Redis.command(["SMEMBERS", "user:#{id}:inverse_block_id_cache"])
    Enum.map(ids, &String.to_integer/1)
  end
end
