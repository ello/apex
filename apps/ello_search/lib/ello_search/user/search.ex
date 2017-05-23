defmodule Ello.Search.User.Search do
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.Network
  alias Ello.Search.{Client, Page, TermSanitizer}
  alias Ello.Search.User.Index

  defstruct [
    terms:          nil,
    current_user:   nil,
    allow_nsfw:     false,
    allow_nudity:   false,
    query:          %{},
    following_ids:  [],
    results:        [],
    per_page:       25,
    page:           1,
    next_page:      2,
    __raw_results:  %{},
    __total_count:  nil,
    __total_pages:  nil,
    __total_pages_remaining: nil,
  ]

  def username_search(opts) do
    __MODULE__
    |> struct(opts)
    |> build_base_query
    |> build_username_query
    |> build_following_ids
    |> build_relationship_query
    |> filter_blocked
    |> search_user_index
  end

  def user_search(opts) do
    __MODULE__
    |> struct(opts)
    |> build_default_user_search_query
    |> build_following_ids
    |> build_relationship_query
    |> filter_private_users
    |> filter_blocked
    |> search_user_index
  end

  defp build_base_query(search_struct), do: %{search_struct | query: base_query()}

  defp base_query do
    %{
      from: 0,
      size: 10,
      query: %{
        bool: %{
          must_not: [
            %{term:   %{username: "wtf"}},
            %{exists: %{field: :locked_at}},
          ],
          must:     [],
          should:   [],
          filter:   [],
        }
      }
    }
  end

  defp build_default_user_search_query(search_struct) do
    search_struct
    |> build_base_query
    |> build_user_query
    |> build_pagination_query
    |> filter_spam
    |> filter_nsfw
    |> filter_nudity
  end

  defp build_pagination_query(%{query: query, page: page, per_page: per_page} = search_struct) do
    page     = page - 1
    per_page = per_page

    updated_query = query
                    |> update_in([:from], &(&1 = page * per_page))
                    |> update_in([:size], &(&1 = per_page))
    %{search_struct | query: updated_query}
  end

  defp build_user_query(%{terms: "@" <> terms} = search_struct), do: build_username_query(%{search_struct | terms: terms})
  defp build_user_query(%{query: query} = search_struct) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    filtered_terms = filter_terms(search_struct)
    updated_query = update_in(query[:query][:bool][:must], &(&1 = %{dis_max: %{queries: [
                                  %{prefix: %{username: %{value: filtered_terms}}},
                                  %{term: %{username: %{value: filtered_terms, boost: boost}}},
                                  %{match: %{name: %{query: filtered_terms, analyzer: "standard", minimum_should_match: "100%"}}} # analyzer: "standard"
                                  ]}}))
    %{search_struct | query: updated_query}
  end

  defp build_username_query(%{terms: "@" <> terms} = search_struct), do: build_username_query(%{search_struct | terms: terms})
  defp build_username_query(%{query: query, terms: terms} = search_struct) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    updated_query = query
                    |> update_in([:query, :bool, :must], &([%{prefix: %{username: %{value: terms}}} | &1]))
                    |> update_in([:query, :bool, :should], &([%{term: %{username: %{value: terms, boost: boost}}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp build_following_ids(%{current_user: nil} = search_struct), do: search_struct
  defp build_following_ids(%{current_user: current_user} = search_struct) do
    following_ids = Network.following_ids(current_user)
    %{search_struct | following_ids: following_ids}
  end

  defp build_relationship_query(%{following_ids: []} = search_struct), do: search_struct
  defp build_relationship_query(%{query: query, following_ids: following_ids} = search_struct) do
    limit = Application.get_env(:ello_search, :following_search_boost_limit)
    boost = Application.get_env(:ello_search, :following_search_boost)
    updated_query = update_in(query[:query][:bool][:should], &([%{constant_score: %{filter: %{terms: %{id: Enum.take(following_ids, limit)}}, boost: boost}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_nsfw(%{allow_nsfw: true} = search_struct), do: search_struct
  defp filter_nsfw(%{query: query} = search_struct) do
    updated_query = update_in(query[:query][:bool][:must_not], &([%{term: %{is_nsfw_user: true}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_nudity(%{allow_nudity: true} = search_struct), do: search_struct
  defp filter_nudity(%{query: query} = search_struct) do
    updated_query = update_in(query[:query][:bool][:must_not], &([%{term: %{posts_nudity: true}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_blocked(%{current_user: nil} = search_struct), do: search_struct
  defp filter_blocked(%{query: query, current_user: current_user} = search_struct) do
    updated_query = update_in(query[:query][:bool][:must_not], &([%{terms: %{id: current_user.all_blocked_ids}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_spam(%{query: query} = search_struct) do
    updated_query = update_in(query[:query][:bool][:must_not], &([%{term: %{is_spammer: true}} | &1]))
    %{search_struct | query: updated_query}
  end

  defp filter_private_users(%{query: query, current_user: nil} = search_struct) do
    updated_query = update_in(query[:query][:bool][:filter], &([%{term: %{is_public: true}} | &1]))
    %{search_struct | query: updated_query}
  end
  defp filter_private_users(search_struct), do: search_struct

  defp filter_terms(%{allow_nsfw: false} = search_struct), do: TermSanitizer.sanitize(search_struct)
  defp filter_terms(%{terms: terms}),                      do: terms

  defp search_user_index(%{query: query, current_user: current_user} = search_struct) do
    measure_segment {:ext, "search_user_index"} do
      results = Client.search(Index.index_name(), Index.doc_types(), query).body
    end

    users = case results["hits"]["hits"] do
      hits when is_list(hits) ->
        ids   = Enum.map(hits, &(String.to_integer(&1["_id"])))
        ids
        |> Network.users(current_user)
        |> user_sorting(ids)
      _ -> []
    end

    Page.pagination_builder(%{search_struct | results: users, __raw_results: results})
  end

  defp user_sorting(users, ids) do
    measure_segment {__MODULE__, "user_sorting"} do
      mapped = Enum.group_by(users, &(&1.id))
      ids
      |> Enum.uniq
      |> Enum.flat_map(&(mapped[&1] || []))
    end
  end
end
