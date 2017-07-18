defmodule Ello.Core.Content.Post do
  use Ecto.Schema
  alias Ello.Core.Network.User
  alias Ello.Core.Contest.{ArtistInviteSubmission}
  alias Ello.Core.Content.{Love, Watch, Asset}

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
    field :categories, {:array, :map}, default: [], virtual: true

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    field :rendered_content, {:array, :map}
    field :rendered_summary, {:array, :map}

    belongs_to :author, User

    belongs_to :reposted_source, __MODULE__
    has_many :reposts, __MODULE__, foreign_key: :reposted_source_id

    belongs_to :parent_post, __MODULE__
    has_many :comments, __MODULE__, foreign_key: :parent_post_id

    field :body, {:array, :map}

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

    has_one :artist_invite_submission, ArtistInviteSubmission
    has_one :artist_invite, through: [:artist_invite_submission, :artist_invite]
  end


  @doc """
  Don't return assets that are unused or invalid.

  In particular done include assets that have a nil attachment field or are not
  included in the content of the post.
  """
  def filter_assets(%__MODULE__{assets: []} = post), do: post
  def filter_assets(%__MODULE__{assets: assets} = post) do
    linked_asset_ids = Enum.reduce post.body, [], fn
      (%{"kind" => "image", "data" => %{"asset_id" => id}}, ids) -> [id | ids]
      (_, ids) -> ids
    end

    filtered_assets = Enum.reject assets, fn
      %{attachment: nil} -> true
      %{attachment: ""}  -> true
      %{id: id}          -> not id in linked_asset_ids
    end

    %{post | assets: filtered_assets}
  end

  @doc """
  Generate the post's SEO level description
  """
  def seo_description(%__MODULE__{} = post) do
    post.body
    |> Enum.filter(&(&1["kind"] == "text"))
    |> Enum.map_join(" ", &(String.trim(&1["data"])))
    |> HtmlSanitizeEx.strip_tags
    |> String.trim
    |> case do
        ""   -> "Discover more amazing work like this on Ello."
        text -> text
    end
  end

  @doc """
  Get the assets associated with a post in order the body defines.

  Includes assets from the reposeted source if present.
  """
  def ordered_assets(nil), do: []
  def ordered_assets(%__MODULE__{assets: assets} = post) do
    ordered_asset_ids = Enum.reduce post.body, [], fn
      (%{"kind" => "image", "data" => %{"asset_id" => id}}, ids) when is_binary(id) -> [String.to_integer(id) | ids]
      (%{"kind" => "image", "data" => %{"asset_id" => id}}, ids) -> [id | ids]
      (_, ids) -> ids
    end
    mapped = Enum.group_by(assets, &(&1.id))
    assets = ordered_asset_ids
             |> Enum.reverse
             |> Enum.flat_map(&(mapped[&1] || []))
    ordered_assets(post.reposted_source) ++ assets
  end

  @doc """
  Get the embed urls associated with a post in order the body defines.

  Includes embeds from the reposeted source if present.
  """
  def ordered_embed_urls(%{reposted_source: %__MODULE__{} = repost} = post),
    do: do_ordered_embed_urls(repost.body ++ post.body)
  def ordered_embed_urls(post),
    do: do_ordered_embed_urls(post.body)

  defp do_ordered_embed_urls(body) do
    body
    |> Enum.filter(&(&1["kind"] == "embed"))
    |> Enum.map(&(&1["data"]["url"]))
  end
end
