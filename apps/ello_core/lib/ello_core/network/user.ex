defmodule Ello.Core.Network.User do
  use Ecto.Schema
  alias Ello.Core.Redis
  alias Ello.Core.Network.{Relationship, User}
  alias User.{Avatar, CoverImage, Settings}

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

    field :avatar_struct, :map, virtual: true
    field :avatar, :string
    field :avatar_metadata, :map
    field :cover_image_struct, :map, virtual: true
    field :cover_image, :string
    field :cover_image_metadata, :map
    field :background_position, :string

    field :is_system_user, :boolean, default: false
    field :is_public, :boolean, default: true
    field :bad_for_seo?, :boolean, default: true
    field :category_ids, {:array, :integer}, default: []
    field :categories, {:array, :map}, default: [], virtual: true

    field :locked_at, :utc_datetime
    field :locked_reason, :string

    field :rendered_links, {:array, :map}

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    embeds_one :settings, Settings
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
    field :inverse_blocked_ids, {:array, :integer}, default: %MapSet{}, virtual: true
    field :blocked_ids, {:array, :integer}, default: %MapSet{}, virtual: true
    field :all_blocked_ids, {:array, :integer}, default: %MapSet{}, virtual: true
  end

  @doc """
  Converts image metadata into avatar and cover image structs
  """
  @spec load_images(user :: t) :: t
  def load_images(user) do
    user
    |> Map.put(:avatar_struct, Avatar.from_user(user))
    |> Map.put(:cover_image_struct, CoverImage.from_user(user))
  end

  @doc """
  Load blocked and inverse blocked ids.

  Typically used on current user to ensure no blocked users/posts are returned.
  """
  @spec preload_blocked_ids(user :: t | nil) :: t | nil
  def preload_blocked_ids(%__MODULE__{id: nil} = user), do: user
  def preload_blocked_ids(nil), do: nil
  def preload_blocked_ids(%__MODULE__{} = user) do
    user = user
           |> Map.put(:inverse_blocked_ids, inverse_blocked_ids(user))
           |> Map.put(:blocked_ids, blocked_ids(user))

    Map.put(user, :all_blocked_ids, MapSet.union(user.inverse_blocked_ids, user.blocked_ids))
  end

  defp blocked_ids(%__MODULE__{id: id}) do
    {:ok, ids} = Redis.command(["SMEMBERS", "user:#{id}:block_id_cache"], name: :blocked_ids)
    ids
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new
  end

  defp inverse_blocked_ids(%__MODULE__{id: id}) do
    {:ok, ids} = Redis.command(["SMEMBERS", "user:#{id}:inverse_block_id_cache"], name: :inverse_blocked_ids)
    ids
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new
  end
end
