defmodule Ello.Search.UserSearch do
  alias Ello.Core.Network
  alias Ello.Search.{Client, UserIndex}

  def username_search(username, %{current_user: current_user}) do
    following_ids = Network.following_ids(current_user)
    query = base_query()
            |> build_username_query(username)
            |> build_relationship_query(following_ids)
            |> filter_blocked(current_user)

    Client.search(UserIndex.index_name(), UserIndex.doc_types(), query)
  end

  def user_search(terms, %{current_user: nil} = opts) do
    query = base_query()
            |> build_user_query(terms)
            |> filter_spam
            |> filter_nsfw(opts[:allow_nsfw])
            |> filter_nudity(opts[:allow_nudity])

    Client.search(UserIndex.index_name(), UserIndex.doc_types(), query)
  end
  def user_search(terms, %{allow_nsfw: allow_nsfw, allow_nudity: allow_nudity, current_user: current_user}) do
    following_ids = Network.following_ids(current_user)
    query = base_query()
            |> build_user_query(terms)
            |> build_relationship_query(following_ids)
            |> filter_spam
            |> filter_nsfw(allow_nsfw)
            |> filter_nudity(allow_nudity)
            |> filter_blocked(current_user)

    Client.search(UserIndex.index_name(), UserIndex.doc_types(), query)
  end

  defp base_query do
    %{
      query: %{
        bool: %{
          must_not: [
            %{term:   %{username: "wtf"}},
            %{exists: %{field: :locked_at}},
          ],
          must:     [],
          should:   [],
        }
      }
    }
  end

  defp build_user_query(query, terms) do
    update_in(query[:query][:bool][:must], &([%{query_string: %{query: terms, fields: ["raw_username^2.5", "raw_name^2", "links", "short_bio", "username^0.01", "name^0.01"]}} | &1]))
  end

  defp build_username_query(query, username) do
    boost = Application.get_env(:ello_search, :username_match_boost_value) || 5.0
    query
    |> update_in([:query, :bool, :must], &([%{fuzzy: %{username: username}} | &1]))
    |> update_in([:query, :bool, :should], &([%{term: %{username: %{value: username, boost: boost}}} | &1]))
  end

  defp build_relationship_query(query, []), do: query
  defp build_relationship_query(query, relationship_ids) do
    limit = Application.get_env(:ello_search, :es_prefix) || 1000
    boost = Application.get_env(:ello_search, :following_search_boost_value) || 15.0
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
end
