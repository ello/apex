defmodule Ello.Search.User.Search do
  alias Ello.Core.Network
  alias Ello.Search.TermSanitizer
  alias Ello.Search.User.Index

  defstruct [
    index:          Index,
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
    total_count:  nil,
    total_pages:  nil,
    total_pages_remaining: nil,
  ]

  def username_search(opts) do
    __MODULE__
    |> struct(opts)
    |> TermSanitizer.sanitize
    |> build_base_query
    |> build_username_query
    |> build_following_ids
    |> build_relationship_query
    |> filter_blocked
    |> Ello.Search.execute
    |> Ello.Search.load_results(&load_users(&1, opts))
    |> Ello.Search.set_next_page
  end

  def user_search(opts) do
    __MODULE__
    |> struct(opts)
    |> TermSanitizer.sanitize
    |> build_default_user_search_query
    |> build_following_ids
    |> build_relationship_query
    |> filter_private_users
    |> filter_blocked
    |> Ello.Search.execute
    |> Ello.Search.load_results(&load_users(&1, opts))
    |> Ello.Search.set_next_page
  end

  defp load_users(ids, %{preloads: preloads} = opts) do
    Network.users(%{
      ids: ids,
      current_user: opts[:current_user],
      preloads: preloads,
    })
  end
  defp load_users(ids, opts) do
    Network.users(%{
      ids: ids,
      current_user: opts[:current_user],
    })
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
    |> Ello.Search.paginate
    |> filter_spam
    |> filter_nsfw
    |> filter_nudity
  end

  defp build_user_query(%{terms: "@" <> terms} = search_struct), do: build_username_query(%{search_struct | terms: terms})
  defp build_user_query(%{terms: terms} = search_struct) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    put_in(search_struct.query[:query][:bool][:must], %{
      dis_max: %{
        queries: [
          %{prefix: %{username: %{value: terms}}},
          %{term: %{username: %{value: terms, boost: boost}}},
          %{match: %{name: %{query: terms, analyzer: "standard", minimum_should_match: "100%"}}}
        ]
      }
    })
  end

  defp build_username_query(%{terms: "@" <> terms} = search_struct), do: build_username_query(%{search_struct | terms: terms})
  defp build_username_query(%{terms: terms} = search_struct) do
    boost = Application.get_env(:ello_search, :username_match_boost)
    search_struct
    |> update_in([Access.key!(:query), :query, :bool, :must], &([%{prefix: %{username: %{value: terms}}} | &1]))
    |> update_in([Access.key!(:query), :query, :bool, :should], &([%{term: %{username: %{value: terms, boost: boost}}} | &1]))
  end

  defp build_following_ids(%{current_user: nil} = search_struct), do: search_struct
  defp build_following_ids(%{current_user: current_user} = search_struct) do
    following_ids = Network.following_ids(current_user)
    %{search_struct | following_ids: following_ids}
  end

  defp build_relationship_query(%{following_ids: []} = search_struct), do: search_struct
  defp build_relationship_query(%{following_ids: following_ids} = search_struct) do
    limit = Application.get_env(:ello_search, :following_search_boost_limit)
    boost = Application.get_env(:ello_search, :following_search_boost)
    update_in(search_struct.query[:query][:bool][:should], &([%{
      constant_score: %{
        filter: %{terms: %{id: Enum.take(following_ids, limit)}},
        boost: boost
      }
    } | &1]))
  end

  defp filter_nsfw(%{allow_nsfw: true} = search_struct), do: search_struct
  defp filter_nsfw(search_struct) do
    update_in(search_struct.query[:query][:bool][:must_not], &([%{term: %{is_nsfw_user: true}} | &1]))
  end

  defp filter_nudity(%{allow_nudity: true} = search_struct), do: search_struct
  defp filter_nudity(search_struct) do
    update_in(search_struct.query[:query][:bool][:must_not], &([%{term: %{posts_nudity: true}} | &1]))
  end

  defp filter_blocked(%{current_user: nil} = search_struct), do: search_struct
  defp filter_blocked(%{current_user: current_user} = search_struct) do
    update_in(search_struct.query[:query][:bool][:must_not], &([%{terms: %{id: current_user.all_blocked_ids}} | &1]))
  end

  defp filter_spam(search_struct) do
    update_in(search_struct.query[:query][:bool][:must_not], &([%{term: %{is_spammer: true}} | &1]))
  end

  defp filter_private_users(%{current_user: nil} = search_struct) do
    update_in(search_struct.query[:query][:bool][:filter], &([%{term: %{is_public: true}} | &1]))
  end
  defp filter_private_users(search_struct), do: search_struct
end
