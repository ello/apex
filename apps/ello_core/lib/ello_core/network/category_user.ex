defmodule Ello.Core.Network.CategoryUser do
  use Ecto.Schema
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Network.User

  @type t :: %__MODULE__{}

  schema "category_users" do
    field :role, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    field :featured_at, :utc_datetime
    belongs_to :featured_by, User

    field :curator_at, :utc_datetime
    belongs_to :curator_by, User

    field :moderator_at, :utc_datetime
    belongs_to :moderator_by, User


    belongs_to :user, User
    belongs_to :category, Category
  end
end
