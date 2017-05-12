defmodule Ello.Core.Discovery.Editorial do
  use Ecto.Schema
  alias Ello.Core.Content.Post

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
end
