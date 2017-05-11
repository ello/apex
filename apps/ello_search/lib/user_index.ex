defmodule Ello.Search.UserIndex do
  alias Ello.Search.Client

  def create do
    Client.create_index(index_name(), settings())
    Client.put_mapping(index_name(), doc_type(), mapping())
  end

  def add(user, overrides \\ %{}) do
    data = %{
      id:           user.id,
      username:     user.username,
      name:         user.name,
      raw_username: user.username,
      raw_name:     raw_name(user.name),
      short_bio:    user.short_bio,
      links:        user.links,
      is_spammer:   false,
      is_public:    user.is_public,
      is_nsfw_user: user.settings.posts_adult_content,
      posts_nudity: user.settings.posts_nudity,
      locked_at:    user.locked_at,
      created_at:   user.created_at,
      updated_at:   user.updated_at
    } |> Map.merge(overrides)
    Client.index_document(index_name(), doc_type(), user.id, data)
    Client.refresh_index(index_name())
  end

  def delete, do: Client.delete_index(index_name())

  def index_name, do: "users"
  def doc_type,   do: "user"
  def doc_types,  do: [doc_type()]

  def settings do
    %{
      settings: %{
        index: %{
            number_of_shards: Application.get_env(:ello_search, :es_default_shards),
            number_of_replicas: Application.get_env(:ello_search, :es_default_replicas)
        },
        analysis: %{
          filter: %{
            autocomplete: %{
              type: "edge_ngram",
              min_gram: 1,
              max_gram: 20
            }
          },
          analyzer: %{
            username_autocomplete: %{
              type: "custom",
              tokenizer: "keyword",
              filter: ["lowercase"]
            },
            name_autocomplete: %{
              type: "custom",
              tokenizer: "whitespace",
              filter: ["lowercase", "autocomplete"]
            }
          }
        }
      }
    }
  end

  def mapping do
    %{
      properties: %{
        id:           %{type: "text"},
        username:     %{type: "text", analyzer: "username_autocomplete"},
        name:         %{type: "text", analyzer: "name_autocomplete"},
        raw_username: %{type: "text", index: false},
        raw_name:     %{type: "text", index: false},
        short_bio:    %{type: "text"},
        links:        %{type: "text"},
        is_spammer:   %{type: "boolean"},
        is_nsfw_user: %{type: "boolean"},
        posts_nudity: %{type: "boolean"},
        locked_at:    %{type: "date"},
        created_at:   %{type: "date"},
        updated_at:   %{type: "date"}
      }
    }
  end

  defp raw_name(nil),  do: nil
  defp raw_name(name), do: String.downcase(name)
end
