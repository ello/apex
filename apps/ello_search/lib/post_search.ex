defmodule Ello.Search.PostSearch do
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.{Content, Network}
  alias Ello.Core.Content
  alias Ello.Search.{Client, PostIndex, TrendingPost, Page, TermSanitizer}
  use Timex

  def post_search(opts) do
    opts
    |> build_client_filter_queries
    |> build_text_content_query(opts)
    |> build_mention_query(opts)
    |> build_hashtag_query(opts)
    |> build_pagination_query(opts[:page], opts[:per_page])
    |> filter_category(opts[:category])
    |> filter_following(opts[:following], opts[:current_user])
    |> filter_days(opts[:within_days])
    |> TrendingPost.build_boosting_queries(opts[:trending], opts[:following], opts[:category])
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

  defp build_text_content_query(query, %{trending: true}), do: query
  defp build_text_content_query(query, %{terms: terms} = opts) do
    if String.starts_with?(terms, "\"") && String.ends_with?(terms, "\"") do
      sliced_terms = String.slice(terms, 1, (String.length(terms) - 2))
      updated_opts = Map.merge(opts, %{terms: sliced_terms})
      update_bool(query, :must, &([%{match_phrase: %{text_content: filter_terms(updated_opts)}} | &1]))
    else
      text_boost = Application.get_env(:ello_search, :text_content_boost_factor)
      update_bool(query, :must, &([%{query_string: %{query: filter_terms(opts), fields: ["text_content"], boost: text_boost}} | &1]))
    end
  end

  defp build_mention_query(query, %{trending: true}), do: query
  defp build_mention_query(query, opts) do
    mention_boost = Application.get_env(:ello_search, :mention_boost_factor)
    update_bool(query, :should, &([%{match: %{mentions: %{query: filter_terms(opts), boost: mention_boost}}} | &1]))
  end

  defp build_hashtag_query(query, %{trending: true}), do: query
  defp build_hashtag_query(query, %{terms: "#" <> _} = opts), do:
    update_bool(query, :must, &([%{match: %{hashtags: %{query: filter_terms(opts)}}} | &1]))
  defp build_hashtag_query(query, _), do: query

  defp filter_nsfw(query, true), do: query
  defp filter_nsfw(query, false), do:
    update_bool(query, :must_not, &([%{term: %{is_adult_content: true}} | &1]))

  defp filter_nudity(query, true), do: query
  defp filter_nudity(query, false) do
    update_bool(query, :must_not, &([%{term: %{has_nudity: true}} | &1]))
  end

  defp filter_blocked(query, nil), do: query
  defp filter_blocked(query, user) do
    update_bool(query, :must_not, &([%{terms: %{author_id: user.all_blocked_ids}} | &1]))
  end

  defp filter_category(query, nil), do: query
  defp filter_category(query, id) do
    update_bool(query, :filter, &([%{terms: %{category_ids: [id]}} | &1]))
  end

  defp filter_following(query, true, %{} = user) do
    limit = Application.get_env(:ello_search, :following_search_boost_limit)
    following_ids = user
                    |> Network.following_ids
                    |> Enum.take(limit)
    update_bool(query, :filter, &([%{terms: %{author_id: following_ids}} | &1]))
  end
  defp filter_following(query, _, _), do: query

  defp filter_terms(%{allow_nsfw: false} = opts), do: TermSanitizer.sanitize(opts[:terms])
  defp filter_terms(opts),                        do: opts[:terms]

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

    posts = case results["hits"]["hits"] do
      hits when is_list(hits) ->
        hits
        |> Enum.map(&(String.to_integer(&1["_id"])))
        |> Content.posts_by_ids(opts)
      _ -> []
    end

    Page.from_results(results, posts, opts)
  end
end
