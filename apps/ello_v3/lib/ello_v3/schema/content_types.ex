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
    field :is_last_page, :boolean
    field :posts, list_of(:post)
  end

  # Assets
  # Content

  object :post do
    field :id, :id
    field :token, :string
    field :reposted_source, :post
    field :assets, list_of(:asset)
    field :author, :user
    field :summary, list_of(:content_blocks), resolve: &post_summary/2
    field :content, list_of(:content_blocks), resolve: &post_content/2
  end

  object :asset do
    field :id, :id
  end

  object :content_blocks do
    field :link_url, :string, resolve: fn(_, %{source: %{"link_url" => url}}) -> {:ok, url} end
    field :kind, :string, resolve: fn(_, %{source: %{"kind" => kind}}) -> {:ok, kind} end
    field :data, :content_data, resolve: fn(_, %{source: %{"data" => data}}) -> {:ok, data} end
  end

  scalar :content_data do
    parse &(&1)
    serialize &(&1)
  end

  defp post_summary(_, %{source: %{reposted_source: %{rendered_summary: summary}}}),
    do: {:ok, summary}
  defp post_summary(_, %{source: %{rendered_summary: post_summary}}),
    do: {:ok, post_summary}

  defp post_content(_, %{source: %{rendered_content: post_content}}),
    do: {:ok, post_content}
end

