defmodule Ello.Search.UsersIndex do
  alias Ello.Core.Repo

  def username_search(username) do
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
    # |> Core.users_by_name
    elastic_url = "http://192.168.99.100:9200"
    index_name  = "test_users"
    search_in   = ["user"]
    search_payload = %{
      filter: %{
        bool: %{
          must_not: [
            %{exists: %{field: :locked_at}},
            %{term: %{is_spammer: true}},
          ]
        }
      }
    }
    Elastix.Search.search(elastic_url, index_name, search_in, search_payload) |> IO.inspect
  end

end
