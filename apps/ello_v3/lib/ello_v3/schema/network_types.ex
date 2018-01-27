defmodule Ello.V3.Schema.NetworkTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
  end
end

