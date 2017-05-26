defmodule Ello.Search.Post.Search do
  alias Ello.Core.{Content, Network}
  alias Ello.Search.TermSanitizer
  alias Ello.Search.Post.{Index, Trending}
  use Timex

  defstruct [
    index:          Index,
    terms:          nil,
    current_user:   nil,
    trending:       false,
    allow_nsfw:     false,
    allow_nudity:   false,
    query:          %{},
    language:       "en",
    category:       nil,
    images_only:    false,
    following:      false,
    results:        [],
    per_page:       25,
    page:           1,
    next_page:      2,
    __raw_results:  %{},
    total_count:  nil,
    total_pages:  nil,
    total_pages_remaining: nil,
  ]

  def post_search(opts) do
    __MODULE__
    |> struct(opts)
    |> build_base_query
    |> build_client_filter_queries
    |> build_text_content_query
    |> build_mention_query
    |> build_hashtag_query
    |> Ello.Search.paginate
    |> filter_has_images
    |> filter_category
    |> filter_following
    |> filter_days
    |> Trending.build_boosting_queries
    |> Ello.Search.execute
    |> Ello.Search.load_results(&Content.posts(Map.put(opts, :ids, &1)))
    |> Ello.Search.set_next_page
  end

  defp build_client_filter_queries(search_struct) do
    search_struct
    |> build_author_query
    |> build_language_query
    |> filter_nsfw
    |> filter_nudity
    |> filter_blocked
  end

  defp build_base_query(search_struct), do: %{search_struct | query: base_query()}

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

  defp build_text_content_query(%{trending: true} = search_struct), do: search_struct
  defp build_text_content_query(%{terms: terms, query: query} = search_struct) do
    field = if String.starts_with?(terms, "\"") && String.ends_with?(terms, "\"") do
      "text_content.raw"
    else
      "text_content"
    end
    updated_query = update_bool(query, :must, &([%{query_string: %{query: filter_terms(search_struct), fields: [field]}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp build_mention_query(%{trending: true} = search_struct), do: search_struct
  defp build_mention_query(%{query: query} = search_struct) do
    mention_boost = Application.get_env(:ello_search, :mention_boost_factor)
    updated_query = update_bool(query, :should, &([%{match: %{mentions: %{query: filter_terms(search_struct), boost: mention_boost}}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp build_hashtag_query(%{terms: "#" <> _, query: query} = search_struct) do
    updated_query = update_bool(query, :must, &([%{match: %{hashtags: %{query: filter_terms(search_struct)}}} | &1]))
    %{search_struct | query: updated_query}
  end
  defp build_hashtag_query(search_struct), do: search_struct

  defp filter_nsfw(%{allow_nsfw: true} = search_struct), do: search_struct
  defp filter_nsfw(%{allow_nsfw: false, query: query} = search_struct) do
    updated_query = update_bool(query, :must_not, &([%{term: %{is_adult_content: true}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_nudity(%{allow_nudity: true} = search_struct), do: search_struct
  defp filter_nudity(%{allow_nudity: false, query: query} = search_struct) do
    updated_query = update_bool(query, :must_not, &([%{term: %{has_nudity: true}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_blocked(%{current_user: nil} = search_struct), do: search_struct
  defp filter_blocked(%{current_user: current_user, query: query} = search_struct) do
    updated_query = update_bool(query, :must_not, &([%{terms: %{author_id: current_user.all_blocked_ids}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_category(%{category: nil} = search_struct), do: search_struct
  defp filter_category(%{category: id, query: query} = search_struct) do
    updated_query = update_bool(query, :filter, &([%{terms: %{category_ids: [id]}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_following(%{query: query, following: true, current_user: current_user} = search_struct) do
    limit = Application.get_env(:ello_search, :following_search_boost_limit)
    following_ids = current_user
                    |> Network.following_ids
                    |> Enum.take(limit)
    updated_query = update_bool(query, :filter, &([%{terms: %{author_id: following_ids}} | &1]))
    %{search_struct | query: updated_query}
  end
  defp filter_following(search_struct), do: search_struct

  defp filter_terms(%{allow_nsfw: false} = search_struct), do: TermSanitizer.sanitize(search_struct)
  defp filter_terms(%{terms: terms}),                      do: terms

  defp filter_has_images(%{images_only: true, query: query} = search_struct) do
    updated_query = update_bool(query, :filter, &([%{term: %{has_images: true}} | &1]))
    %{search_struct | query: updated_query}
  end
  defp filter_has_images(search_struct), do: search_struct

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

  defp build_author_query(%{query: query, current_user: nil} = search_struct) do
    author_query = filter_private_authors(author_base_query())
    updated_query = update_bool(query, :filter, &([author_query | &1]))
    %{search_struct | query: updated_query}
  end
  defp build_author_query(%{query: query} = search_struct) do
    updated_query = update_bool(query, :filter, &([author_base_query() | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_private_authors(author_query) do
    update_in(author_query[:has_parent][:query][:bool][:filter], &([%{term: %{is_public: true}} | &1]))
  end

  defp build_language_query(%{language: nil} = search_struct),  do: search_struct
  defp build_language_query(%{language: "en"} = search_struct), do: search_struct
  defp build_language_query(%{query: query, language: language} = search_struct) do
    language_boost = Application.get_env(:ello_search, :language_boost_factor)
    updated_query = update_bool(query, :should, &([%{term: %{detected_language: %{value: language, boost: language_boost}}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_days(%{query: query, within_days: within_days} = search_struct) when is_integer(within_days) do
    date = Timex.now
           |> Timex.shift(days: -within_days)
           |> Timex.format!("%Y-%m-%d", :strftime)
    updated_query = update_bool(query, :filter, &([%{range: %{created_at: %{gte: date}}} | &1]))
    %{search_struct | query: updated_query}
  end
  defp filter_days(search_struct), do: search_struct

  defp update_bool(query, type, fun) do
    update_in(query[:query][:function_score][:query][:bool][type], fun)
  end
end
