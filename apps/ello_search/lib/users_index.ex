defmodule Ello.Search.UsersIndex do
  alias Ello.Core.{Repo, Network}

  def username_search(username, %{current_user: current_user, allow_nsfw: allow_nsfw, allow_nudity: allow_nudity}) do
      # term = termify_operators(URI.decode(options[:term]).strip)

      # exclude_nsfw   = options.fetch(:exclude_nsfw, false)
      # exclude_nudity = options.fetch(:exclude_nudity, false)
      # is_mention_search = term.starts_with?('@')
      # is_quotes_search = term.starts_with?('"')

      # # Unmention the term if needed
      # term = term[1..-1] if is_mention_search

      # term = Sanitizers::TermsSanitizer.sanitize(term) if exclude_nsfw

      # page_options = { term: term, page: options.delete(:page), per_page: options.delete(:per_page) }
      # raw_query_hash = raw_query(current_user, term, exclude_nsfw, exclude_nudity, is_quotes_search)
      # results = query(raw_query_hash)

      # paginate(results.only(*include_fields(options)), page_options)

    # username
    # |> build_username_query
    # |> ES.search
    # |> Enum.map(&(&1.id))
    # |> Core.users_by_name{
    #
        # filtered: {
        #   query: {
        #     bool: {
        #       should: queries
        #     }
        #   },
        #   filter: common_filters(current_user, exclude_nsfw, exclude_nudity)
        # }
      # }
          # must: [
          #   %{match: %{username: username}}
          # ]
            # %{match: %{username: username}}
          # must: [
          #   %{multi_match: %{query: username, type: "most_fields", fields: ["username"]}}
          # ]
    elastic_url = "http://192.168.99.100:9200"
    index_name  = "test_users"
    search_in   = ["user"]
    following_ids = Network.following_ids(current_user)
    search_payload = %{
      query: %{
        bool: %{
          must_not: [
            %{exists: %{field: :locked_at}},
          ],
          must: [
            %{fuzzy: %{username: username}},
          ],
          should: [
            %{term: %{username: %{value: username, boost: 3.0}}},
            %{terms: %{id: following_ids}},
          ],
        }
      }
    } |> filter_nsfw(allow_nsfw)
      |> filter_nudity(allow_nudity)
      |> filter_blocked(current_user)
    Elastix.Search.search(elastic_url, index_name, search_in, search_payload) |> IO.inspect
  end

  defp filter_nsfw(payload, true), do: payload
  defp filter_nsfw(payload, false) do
    update_in(payload[:query][:bool][:must_not], &([%{term: %{is_nsfw_user: true}} | &1]))
  end

  defp filter_nudity(payload, true), do: payload
  defp filter_nudity(payload, false) do
    update_in(payload[:query][:bool][:must_not], &([%{term: %{posts_nudity: true}} | &1]))
  end

  defp filter_blocked(payload, user) do
    update_in(payload[:query][:bool][:must_not], &([ %{terms: %{id: user.all_blocked_ids}} | &1]))
  end

  defp filter_spam(payload) do
    update_in(payload[:query][:bool][:must_not], &([%{term: %{is_spammer: true}} | &1]))
  end
end
