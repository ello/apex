defmodule Ello.Core.Network.CategoryUser do
  use Ecto.Schema
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Network.User

  @type t :: %__MODULE__{}

  schema "category_users" do
    field :role, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :user, User
    belongs_to :category, Category
  end
end
