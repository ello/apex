defmodule Ello.V3.Schema.NetworkTypes do
  use Absinthe.Schema.Notation

  # Flags
  # Settings
  # Ask colin for what he needs
  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
  end
end

