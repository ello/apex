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
              raw_username: user.username,
              short_bio:    user.short_bio,
              links:        user.links,
              is_spammer:   false,
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
  def doc_types,  do: [doc_type]

  def settings do
    %{
      settings: %{
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
        raw_username: %{type: "text", index: false},
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
end
