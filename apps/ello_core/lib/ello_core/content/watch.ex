defmodule Ello.Core.Content.Watch do
  use Ecto.Schema
  alias Ello.Core.{
    Content.Post,
    Network.User
  }

  @type t :: %__MODULE__{}

  schema "watches" do
    belongs_to :post, Post
    belongs_to :user, User
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime
  end
end
