defmodule Ello.Core.Discovery.Category do
  use Ecto.Schema
  alias Ello.Core.Discovery.{
    CategoryPost,
    Promotional,
  }
  alias __MODULE__.TileImage

  @type t :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :roshi_slug, :string
    field :level, :string
    field :order, :integer
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :tile_image, :string
    field :tile_image_metadata, :map
    field :tile_image_struct, :map, virtual: true
    field :allow_in_onboarding, :boolean, default: false
    field :description, :string
    field :is_sponsored, :boolean, default: false
    field :header, :string
    field :cta_caption, :string
    field :cta_href, :string
    field :uses_page_promotionals, :boolean
    field :is_creator_type, :boolean, default: false

    has_many :promotionals, Promotional
    has_many :category_posts, CategoryPost
  end

  @doc """
  Converts image metadata into title_image_struct
  """
  @spec load_images(category :: t) :: t
  def load_images(category) do
    Map.put(category, :tile_image_struct, TileImage.from_category(category))
  end
end
