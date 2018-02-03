defmodule Ello.V3.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  import Ello.V3.Schema.Helpers
  alias Ello.Core.Content.{
    Post,
    Love,
    Watch,
  }

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

  object :post do
    field :id, :id
    field :token, :string
    field :created_at, :datetime
    field :reposted_source, :post
    field :assets, list_of(:asset)
    field :categories, list_of(:category)
    field :author, :user
    field :summary, list_of(:content_blocks), resolve: &post_summary/2
    field :content, list_of(:content_blocks), resolve: &post_content/2
    field :repost_content, list_of(:content_blocks), resolve: &repost_content/2
    field :post_stats, :post_stats, resolve: &source_self/2
    field :current_user_state, :post_current_user_state, resolve: &source_self/2
    field :artist_invite_id, :string, resolve: &artist_invite_id/2
    field :artist_invite_submission, :artist_invite_submission, resolve: &artist_invite_submission/2
  end

  object :post_stats do
    field :loves_count, :integer
    field :comments_count, :integer
    field :reposts_count, :integer
    field :views_count, :integer
  end

  object :post_current_user_state do
    field :reposted, :boolean, resolve: &post_reposted/2
    field :loved, :boolean, resolve: &post_loved/2
    field :watching, :boolean, resolve: &post_watching/2
  end

  object :content_blocks do
    field :link_url, :string, resolve: &str_get/2
    field :kind, :string, resolve: &str_get/2
    field :data, :content_data, resolve: &str_get/2
    field :links, :content_links, resolve: &str_get/2
  end

  object :content_links do
    field :assets, :id, resolve: &str_get/2
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


  defp post_reposted(_, %{source: %{repost_from_current_user: %Post{}}}), do: {:ok, true}
  defp post_reposted(_, _), do: {:ok, false}

  defp post_loved(_, %{source: %{love_from_current_user: %Love{deleted: deleted}}}), do: {:ok, !deleted}
  defp post_loved(_, _), do: {:ok, false}

  defp post_watching(_, %{source: %{watch_from_current_user: %Watch{}}}), do: {:ok, true}
  defp post_watching(_, _), do: {:ok, false}

  defp repost_content(_, %{source: %{reposted_source: %{rendered_content: c}}}), do: {:ok, c}
  defp repost_content(_, _), do: {:ok, []}

  defp artist_invite_id(_, %{source: post}) do
    case get_submission(post) do
      nil -> {:ok, nil}
      sub -> {:ok, "#{sub.artist_invite_id}"}
    end
  end

  defp artist_invite_submission(_, %{source: post}) do
    case get_submission(post) do
      nil        -> {:ok, %{slug: nil, title: nil, status: nil}}
      submission -> {:ok, %{
        id: submission.id,
        slug: submission.artist_invite.slug,
        title: submission.artist_invite.title,
        status: submission_status(submission)
      }}
    end
  end

  defp get_submission(%{reposted_source: %{artist_invite_submission: %{id: _} = s}}), do: s
  defp get_submission(%{artist_invite_submission: %{id: _} = s}), do: s
  defp get_submission(_), do: nil

  defp submission_status(%{status: "approved"}), do: "approved"
  defp submission_status(%{status: "selected", artist_invite: %{status: "closed"}}), do: "selected"
  defp submission_status(%{status: "selected"}), do: "approved"
  defp submission_status(_), do: nil
end

