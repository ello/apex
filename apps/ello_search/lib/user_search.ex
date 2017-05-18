defmodule Ello.Search.UserSearch do
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.Network
  alias Ello.Search.{Client, UserIndex, Page, TermSanitizer}

  def username_search(%{current_user: current_user} = opts) do
    following_ids = Network.following_ids(current_user)
    base_query()
    |> build_username_query(opts)
    |> build_relationship_query(following_ids)
    |> filter_blocked(current_user)
    |> search_user_index(opts)
  end

  def user_search(%{current_user: nil} = opts) do
    opts
    |> build_default_user_search_query
    |> filter_private_users
    |> search_user_index(opts)
  end
  def user_search(%{current_user: current_user} = opts) do
    following_ids = Network.following_ids(current_user)
    opts
    |> build_default_user_search_query
    |> build_relationship_query(following_ids)
    |> filter_blocked(current_user)
    |> search_user_index(opts)
  end

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

  defp build_default_user_search_query(opts) do
    base_query()
    |> build_user_query(opts)
    |> build_pagination_query(opts[:page], opts[:per_page])
    |> filter_spam
    |> filter_nsfw(opts[:allow_nsfw])
    |> filter_nudity(opts[:allow_nudity])
  end

  defp build_pagination_query(query, page, per_page) do
    page = page - 1
    query
    |> update_in([:from], &(&1 = page * per_page))
    |> update_in([:size], &(&1 = per_page))
  end

  defp build_user_query(query, %{terms: "@" <> terms} = opts), do: build_username_query(query, Map.merge(opts, %{terms: terms}))
  defp build_user_query(query, %{terms: terms} = opts) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    filtered_terms = filter_terms(terms, opts[:allow_nsfw])
    update_in(query[:query][:bool][:must], &(&1 = %{dis_max: %{queries: [
        %{prefix: %{username: %{value: filtered_terms}}},
        %{term: %{username: %{value: filtered_terms, boost: boost}}},
        %{match: %{name: %{query: filtered_terms, analyzer: "standard", minimum_should_match: "100%"}}} # analyzer: "standard"
    ]}}))
  end

  defp build_username_query(query, %{terms: terms}) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    query
    |> update_in([:query, :bool, :must], &([%{prefix: %{username: %{value: terms}}} | &1]))
    |> update_in([:query, :bool, :should], &([%{term: %{username: %{value: terms, boost: boost}}} | &1]))
  end

  defp build_relationship_query(query, []), do: query
  defp build_relationship_query(query, relationship_ids) do
    limit = Application.get_env(:ello_search, :following_search_boost_limit)
    boost = Application.get_env(:ello_search, :following_search_boost)
    update_in(query[:query][:bool][:should], &([%{constant_score: %{filter: %{terms: %{id: Enum.take(relationship_ids, limit)}}, boost: boost}} | &1]))
  end

  defp filter_nsfw(query, true), do: query
  defp filter_nsfw(query, false) do
    update_in(query[:query][:bool][:must_not], &([%{term: %{is_nsfw_user: true}} | &1]))
  end

  defp filter_nudity(query, true), do: query
  defp filter_nudity(query, false) do
    update_in(query[:query][:bool][:must_not], &([%{term: %{posts_nudity: true}} | &1]))
  end

  defp filter_blocked(query, user) do
    update_in(query[:query][:bool][:must_not], &([%{terms: %{id: user.all_blocked_ids}} | &1]))
  end

  defp filter_spam(query) do
    update_in(query[:query][:bool][:must_not], &([%{term: %{is_spammer: true}} | &1]))
  end

  defp filter_private_users(query) do
    update_in(query[:query][:bool][:filter], &([%{term: %{is_public: true}} | &1]))
  end

  defp filter_terms(terms, true), do: terms
  defp filter_terms(terms, _),    do: TermSanitizer.sanitize(terms)

  defp search_user_index(query, opts \\ %{}) do
    measure_segment {:ext, "search_user_index"} do
      results = Client.search(UserIndex.index_name(), UserIndex.doc_types(), query).body
    end

    users = case results["hits"]["hits"] do
      hits when is_list(hits) ->
        ids   = Enum.map(hits, &(String.to_integer(&1["_id"])))
        ids
        |> Network.users(opts[:current_user])
        |> user_sorting(ids)
      _ -> []
    end

    Page.from_results(results, users, opts)
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
