defmodule Ello.Core.Discovery.CategoryPost do
  use Ecto.Schema
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Content.Post
  alias Ello.Core.Network.User

  @type t :: %__MODULE__{}

  schema "category_posts" do
    field :status, :string
    field :submitted_at, :utc_datetime
    field :featured_at, :utc_datetime
    field :unfeatured_at, :utc_datetime
    field :removed_at, :utc_datetime

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :post, Post
    belongs_to :category, Category
    belongs_to :submitted_by, User
    belongs_to :featured_by, User
    belongs_to :removed_by, User
    belongs_to :unfeatured_by, User
  end
end
