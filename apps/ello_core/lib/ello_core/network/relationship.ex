defmodule Ello.Core.Network.Relationship do
  use Ecto.Schema
  alias Ello.Core.Network.User

  schema "followerships" do
    field :priority, :string
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :owner,   User
    belongs_to :subject, User
  end
end
