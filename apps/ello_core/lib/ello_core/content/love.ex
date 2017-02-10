defmodule Ello.Core.Content.Love do
  use Ecto.Schema
  alias Ello.Core.{
    Content.Post,
    Network.User
  }

  @type t :: %__MODULE__{}

  schema "loves" do
    belongs_to :post, Post
    belongs_to :user, User
    field :deleted, :boolean, default: false
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime
  end
end
