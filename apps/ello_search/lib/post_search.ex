defmodule Ello.Search.PostSearch do
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.Content
  alias Ello.Search.{Client, PostIndex, TrendingPost, Page}
  use Timex

  def post_search(opts) do
    opts
    |> build_client_filter_queries
    |> build_text_content_query(opts[:terms])
    |> build_mention_query(opts[:terms])
    |> build_hashtag_query(opts[:terms])
    |> build_pagination_query(opts[:page], opts[:per_page])
    |> filter_days(opts[:within_days])
    |> TrendingPost.build_boosting_queries(opts[:trending])
    |> search_post_index(opts)
  end

  defp build_client_filter_queries(opts) do
    base_query()
    |> build_author_query(opts[:current_user])
    |> build_language_query(opts[:language])
    |> filter_nsfw(opts[:allow_nsfw])
    |> filter_nudity(opts[:allow_nudity])
    |> filter_blocked(opts[:current_user])
  end

  defp base_query do
    %{
      from: 0,
      size: 10,
      stored_fields: [],
      query: %{
        function_score: %{
          query: %{
            bool: %{
              must:     [],
              should:   [],
              filter:   [],
              must_not: [
                %{term: %{is_comment: true}},
                %{term: %{is_hidden:  true}},
                %{term: %{is_repost:  true}},
              ]
            }
          },
          functions: [],
          score_mode: "sum",
          boost_mode: "sum"
        }
      }
    }
  end

  defp build_text_content_query(query, nil), do: query
  defp build_text_content_query(query, terms) do
    text_boost = Application.get_env(:ello_search, :text_content_boost_factor)
    update_bool(query, :must, &([%{query_string: %{query: terms, fields: ["text_content"], boost: text_boost}} | &1]))
  end

  defp build_mention_query(query, nil), do: query
  defp build_mention_query(query, terms) do
    mention_boost = Application.get_env(:ello_search, :mention_boost_factor)
    update_bool(query, :should, &([%{match: %{mentions: %{query: terms, boost: mention_boost}}} | &1]))
  end

  defp build_hashtag_query(query, nil), do: query
  defp build_hashtag_query(query, terms) do
    hashtag_boost = Application.get_env(:ello_search, :hashtag_boost_factor)
    update_bool(query, :should, &([%{match: %{hashtags: %{query: terms, boost: hashtag_boost}}} | &1]))
  end

  defp filter_nsfw(query, true), do: query
  defp filter_nsfw(query, false) do
    update_bool(query, :must_not, &([%{term: %{is_adult_content: true}} | &1]))
  end

  defp filter_nudity(query, true), do: query
  defp filter_nudity(query, false) do
    update_bool(query, :must_not, &([%{term: %{has_nudity: true}} | &1]))
  end

  defp filter_blocked(query, nil), do: query
  defp filter_blocked(query, user) do
    update_bool(query, :must_not, &([%{terms: %{author_id: user.all_blocked_ids}} | &1]))
  end

  defp author_base_query do
    %{
      has_parent: %{
        parent_type: "author",
        query: %{
          bool: %{
            filter: [
              %{term: %{locked_out: false}},
              %{term: %{is_spammer: false}},
            ]
          }
        }
      }
    }
  end

  defp build_author_query(query, nil) do
    author_query = filter_private_authors(author_base_query())
    update_bool(query, :filter, &([author_query | &1]))
  end
  defp build_author_query(query, _current_user) do
    update_bool(query, :filter, &([author_base_query() | &1]))
  end

  defp filter_private_authors(author_query) do
    update_in(author_query[:has_parent][:query][:bool][:filter], &([%{term: %{is_public: true}} | &1]))
  end

  defp build_pagination_query(query, nil, nil), do: query
  defp build_pagination_query(query, nil, per_page), do:
    build_pagination_query(query, "1", per_page)
  defp build_pagination_query(query, page, per_page) do
    page     = String.to_integer(page) - 1
    per_page = String.to_integer(per_page)

    query
    |> update_in([:from], &(&1 = page * per_page))
    |> update_in([:size], &(&1 = per_page))
  end

  defp build_language_query(query, nil), do: query
  defp build_language_query(query, language) do
    language_boost = Application.get_env(:ello_search, :language_boost_factor)
    update_bool(query, :should, &([%{term: %{detected_language: %{value: language, boost: language_boost}}} | &1]))
  end

  defp filter_days(query, within_days) when is_integer(within_days) do
    date = Timex.now
           |> Timex.shift(days: -within_days)
           |> Timex.format!("%Y-%m-%d", :strftime)
    update_bool(query, :filter, &([%{range: %{created_at: %{gte: date}}} | &1]))
  end
  defp filter_days(query, _), do: query

  defp update_bool(query, type, fun) do
    update_in(query[:query][:function_score][:query][:bool][type], fun)
  end

  defp search_post_index(query, opts) do
    measure_segment {:ext, "search_post_index"} do
      results = Client.search(PostIndex.index_name(), [PostIndex.post_doc_type], query).body
    end

    posts = results
            |> get_in(["hits", "hits"])
            |> Enum.map(&(String.to_integer(&1["_id"])))
            |> Content.posts_by_ids(opts)

    Page.from_results(results, posts, opts)
  end
end
