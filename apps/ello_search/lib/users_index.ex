defmodule Ello.Search.UsersIndex do
  alias Ello.Search.Client
  alias Ello.Core.Network

  def username_search(username, %{current_user: current_user, allow_nsfw: allow_nsfw, allow_nudity: allow_nudity}) do
    following_ids  = Network.following_ids(current_user)
    query = base_query()
            |> build_username_query(username)
            |> build_relationship_query(following_ids)
            |> filter_nsfw(allow_nsfw)
            |> filter_nudity(allow_nudity)
            |> filter_blocked(current_user)
            |> filter_locked

    Client.search(index_name(), doc_types(), query)
  end

  defp index_name, do: "users"
  defp doc_types, do: ["user"]

  defp base_query do
    %{
      query: %{
        bool: %{
          must_not: [],
          must: [],
          should: [],
        }
      }
    }
  end

  defp build_username_query(query, username) do
    query
    |> update_in([:query, :bool, :must], &([%{fuzzy: %{username: username}} | &1]))
    |> update_in([:query, :bool, :should], &([%{term: %{username: %{value: username, boost: 5.0}}} | &1]))
  end

  defp build_relationship_query(query, []), do: query
  defp build_relationship_query(query, relationship_ids) do
    limit = Application.get_env(:ello_search, :es_prefix) || 1000
    update_in(query[:query][:bool][:should], &([%{constant_score: %{filter: %{terms: %{id: Enum.take(relationship_ids, limit)}}, boost: 10.0}} | &1]))
  end

  defp filter_locked(query) do
    update_in(query[:query][:bool][:must_not], &([%{exists: %{field: :locked_at}} | &1]))
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
