defmodule Ello.V3.Schema.ContestTypes do
  use Absinthe.Schema.Notation

  object :artist_invite_submission do
    field :slug, :string
    field :title, :string
    field :status, :string
  end
end
