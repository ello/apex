defmodule Ello.Search.UserSearch do
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.Network
  alias Ello.Search.{Client, UserIndex}

  def username_search(username, %{current_user: current_user}) do
    following_ids = Network.following_ids(current_user)
    base_query()
    |> build_username_query(username)
    |> build_relationship_query(following_ids)
    |> filter_blocked(current_user)
    |> search_user_index
  end

  def user_search(terms, %{current_user: nil} = opts) do
    terms
    |> build_default_user_search_query(opts)
    |> filter_private_users
    |> search_user_index
  end
  def user_search(terms, %{current_user: current_user} = opts) do
    following_ids = Network.following_ids(current_user)
    terms
    |> build_default_user_search_query(opts)
    |> build_relationship_query(following_ids)
    |> filter_blocked(current_user)
    |> search_user_index
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

  defp build_default_user_search_query(terms, opts) do
    base_query()
    |> build_user_query(terms)
    |> build_pagination_query(opts[:page], opts[:per_page])
    |> filter_spam
    |> filter_nsfw(opts[:allow_nsfw])
    |> filter_nudity(opts[:allow_nudity])
  end

  defp build_pagination_query(query, nil, nil), do: query
  defp build_pagination_query(query, page, per_page) do
    query
    |> update_in([:from], &(&1 = page * per_page))
    |> update_in([:size], &(&1 = per_page))
  end

  defp build_user_query(query, terms) do
    update_in(query[:query][:bool][:must], &([%{query_string: %{query: terms, fields: ["raw_username^2.5", "raw_name^2", "links", "short_bio", "username^0.01", "name^0.01"]}} | &1]))
  end

  defp build_username_query(query, username) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    query
    |> update_in([:query, :bool, :must], &([%{fuzzy: %{username: username}} | &1]))
    |> update_in([:query, :bool, :should], &([%{term: %{username: %{value: username, boost: boost}}} | &1]))
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

  defp search_user_index(query) do
    measure_segment {:ext, "search_user_index"} do
      ids = Client.search(UserIndex.index_name(), UserIndex.doc_types(), query).body["hits"]["hits"]
            |> Enum.map(&(String.to_integer(&1["_id"])))
    end

    ids
    |> Network.users
    |> user_sorting(ids)
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
