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
    field :link_url, :string, resolve: &str_get/2
    field :kind, :string, resolve: &str_get/2
    field :data, :content_data, resolve: &str_get/2
    field :links, :content_links, resolve: &str_get/2
  end

  object :content_links do
    field :asset_id, :id, resolve: &str_get/2
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


  # Gets a json field propery with a string instead of atom name.
  defp str_get(_, %{source: source, definition: %{schema_node: %{identifier: name}}}) do
    {:ok, Map.get(source, "#{name}")}
  end
end

