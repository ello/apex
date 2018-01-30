defmodule Ello.V3.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  enum :stream_type do
    value :recent
    value :featured
    value :trending
  end

  object :post_stream do
    field :next, :string
    field :per_page, :integer
    field :posts, list_of(:post)
  end

  # Assets
  # Content

  object :post do
    field :id, :id
    field :token, :string
    field :calculated, :string, resolve: fn(_args, %{source: post}) ->
      {:ok, "#{post.id}-yolo"}
    end
    field :assets, list_of(:asset)
    field :author, :user
  end

  object :asset do
    field :id, :id
  end
end

