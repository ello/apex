defmodule Ello.Core.Content.Asset do
  use Ecto.Schema
  alias Ello.Core.{ Network.User, Content.Post }

  @type t :: %__MODULE__{}

  schema "assets" do
    field :attachment_struct, :map, virtual: true
    field :attachment, :string
    field :attachment_metadata, :map

    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :user, User
    belongs_to :post, Post
  end

end
