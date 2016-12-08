defmodule Ello.User do
  use Ello.Web, :model

  schema "users" do
    field :email, :string
    field :username, :string
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime
  end
end
