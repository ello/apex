defmodule Ello.Relationship do
  use Ello.Web, :model

  schema "followerships" do
    field :priority, :string
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :owner, Ello.User
    belongs_to :subject, Ello.User
  end
end
