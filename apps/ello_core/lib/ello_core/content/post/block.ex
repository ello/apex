defmodule Ello.Core.Content.Post.Block do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :kind, :string
    field :data, :map
  end
end
