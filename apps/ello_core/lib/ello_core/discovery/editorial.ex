defmodule Ello.Core.Discovery.Editorial do
  use Ecto.Schema
  alias Ello.Core.Content.Post
  alias Ello.Core.Image

  @type t :: %__MODULE__{}

  schema "editorials" do
    field :published_position, :integer
    field :preview_position, :integer
    field :kind, :string
    field :content, :map

    field :one_by_one_image, :string
    field :one_by_two_image, :string
    field :two_by_one_image, :string
    field :two_by_two_image, :string

    field :one_by_one_image_metadata, :map
    field :one_by_two_image_metadata, :map
    field :two_by_one_image_metadata, :map
    field :two_by_two_image_metadata, :map

    field :one_by_one_image_struct, :map, virtual: true
    field :one_by_two_image_struct, :map, virtual: true
    field :two_by_one_image_struct, :map, virtual: true
    field :two_by_two_image_struct, :map, virtual: true

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :post, Post
  end

  @doc """
  Converts image filename and metadata into a struct for serialization
  """
  @spec build_images(editorial :: t) :: t
  def build_images(editorial) do
    editorial
    |> Map.put(:one_by_one_image_struct, image_struct(editorial, :one_by_one_image))
    |> Map.put(:one_by_two_image_struct, image_struct(editorial, :one_by_two_image))
    |> Map.put(:two_by_one_image_struct, image_struct(editorial, :two_by_one_image))
    |> Map.put(:two_by_two_image_struct, image_struct(editorial, :two_by_two_image))
  end

  def image_struct(editorial, field) do
    field_string = Atom.to_string(field)
    metadata = Map.get(editorial, String.to_atom("#{field_string}_metadata"))
    filename = Map.get(editorial, field)
    %Image{
      filename: filename,
      path:     "/uploads/editorial/#{field_string}/#{editorial.id}",
      versions: Image.Version.from_metadata(metadata, filename),
    }
  end
end
