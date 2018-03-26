defmodule Ello.Search.Post.Index do
  alias Ello.Search.Client
  alias Ello.Core.{Discovery, Repo}

  def create do
    Client.create_index(index_name(), settings())
    Client.put_mapping(index_name(), post_doc_type(), post_mapping())
    Client.put_mapping(index_name(), author_doc_type(), author_mapping())
  end

  def add(post, overrides \\ %{}) do
    post_data   = assemble_post_data(post, overrides)
    author_data = assemble_author_data(post.author, overrides)

    Client.index_document(index_name(), author_doc_type(), post.author.id, author_data)
    Client.index_document(index_name(), post_doc_type(), post.id, post_data, %{parent: post.author.id})
    Client.refresh_index(index_name())
  end

  defp assemble_post_data(post, overrides) do
    post = Repo.preload(post, :categories)
    %{
      id:                post.id,
      created_at:        post.created_at,
      updated_at:        post.updated_at,
      token:             post.token,
      author_id:         post.author_id,
      text_content:      text_content(post),
      hashtags:          hashtags(post),
      mentions:          post.mentioned_usernames,
      detected_language: detected_language(post),
      is_adult_content:  post.is_adult_content,
      has_nudity:        post.has_nudity,
      is_disabled:       post.is_disabled,
      is_hidden:         false,
      is_repost:         !!post.reposted_source,
      is_comment:        !!post.parent_post,
      comment_count:     0,
      repost_count:      0,
      love_count:        0,
      view_count:        0,
      alt_text:          "",
      is_saleable:       post.is_saleable,
      category_ids:      Enum.map(post.categories, &(&1.id)),
      has_images:        has_images(post),
    } |> Map.merge(overrides[:post] || %{})
  end

  defp assemble_author_data(author, overrides) do
    %{
      id:                 author.id,
      created_at:         author.created_at,
      updated_at:         author.updated_at,
      name:               author.name,
      username:           author.username,
      short_bio:          author.short_bio,
      links:              author.links,
      locked_out:         !!author.locked_at,
      post_count:         0,
      comment_count:      0,
      follower_count:     0,
      is_spammer:         false,
      is_system_user:     author.is_system_user,
      is_featured_user:   Enum.any?(author.category_ids),
      has_avatar:         !!author.avatar,
      is_public:          author.is_public,
      category_ids:       author.category_ids,
      category_names:     category_names(author.category_ids),
      is_hireable:        author.settings.is_hireable,
      is_collaborateable: author.settings.is_collaborateable,
      location:           author.location,
      coordinates:        coordinates(author)
    } |> Map.merge(overrides[:author] || %{})
  end

  def delete, do: Client.delete_index(index_name())

  def index_name,      do: Application.get_env(:ello_search, :posts_active_index_name)
  def author_doc_type, do: "author"
  def post_doc_type,   do: "post"
  def doc_types,       do: [post_doc_type(), author_doc_type()]
  def settings do
    %{
      settings: %{
        index: %{
          number_of_shards: Application.get_env(:ello_search, :es_default_shards),
          number_of_replicas: Application.get_env(:ello_search, :es_default_replicas)
        },
        analysis: %{
          analyzer: %{
            default_text_analyzer: %{
              type: "custom",
              tokenizer: "standard",
              filter: ["lowercase"]
            }
          }
        }
      }
    }
  end

  def author_mapping do
    %{
      properties: %{
        id:                 %{type: "integer"},
        created_at:         %{type: "date"},
        updated_at:         %{type: "date"},
        name:               %{type: "text"},
        username:           %{type: "text"},
        short_bio:          %{type: "text"},
        links:              %{type: "text"},
        locked_out:         %{type: "boolean"},
        post_count:         %{type: "integer"},
        comment_count:      %{type: "integer"},
        follower_count:     %{type: "integer"},
        is_spammer:         %{type: "boolean"},
        is_system_user:     %{type: "boolean"},
        is_featured_user:   %{type: "boolean"},
        has_avatar:         %{type: "boolean"},
        is_public:          %{type: "boolean"},
        category_ids:       %{type: "text"},
        category_names:     %{type: "text"},
        is_hireable:        %{type: "boolean"},
        is_collaborateable: %{type: "boolean"},
        location:           %{type: "text"},
        coordinates:        %{type: "geo_point"}
      }
    }
  end

  def post_mapping do
    %{
      "_parent" => %{type: author_doc_type()},
      properties: %{
        id:                %{type: "integer"},
        created_at:        %{type: "date"},
        updated_at:        %{type: "date"},
        token:             %{type: "text"},
        author_id:         %{type: "integer"},
        text_content: %{
          type:     "text",
          fields:   %{raw: %{type: "text", analyzer: "default_text_analyzer"}},
          analyzer: "english",
        },
        hashtags:          %{type: "text"},
        mentions:          %{type: "text"},
        detected_language: %{type: "text", index: false},
        is_adult_content:  %{type: "boolean"},
        has_nudity:        %{type: "boolean"},
        is_disabled:       %{type: "boolean"},
        is_hidden:         %{type: "boolean"},
        is_repost:         %{type: "boolean"},
        is_comment:        %{type: "boolean"},
        comment_count:     %{type: "integer"},
        repost_count:      %{type: "integer"},
        love_count:        %{type: "integer"},
        view_count:        %{type: "integer"},
        alt_text:          %{type: "text", analyzer: "english"},
        is_saleable:       %{type: "boolean"},
        has_images:        %{type: "boolean"},
      }
    }
  end

  defp category_names(category_ids) when length(category_ids) == 0, do: []
  defp category_names(category_ids) do
    %{ids: category_ids, images: false}
    |> Discovery.categories
    |> Enum.map(&(&1.name))
  end

  defp text_content(%{reposted_source: reposted_source} = post) when reposted_source != nil do
    text_content(post, text_data(post.reposted_source.body))
  end
  defp text_content(post, repost_text_data \\ []) do
    repost_text_data ++ text_data(post.body)
    |> Enum.map_join(" ", &(String.trim(&1["data"])))
    |> HtmlSanitizeEx.strip_tags
    |> String.trim
  end

  defp text_data(body) when is_list(body), do: Enum.filter(body, &(&1["kind"] == "text"))

  defp hashtags(post) do
    case Regex.run(~r/\B(#\w+)/, text_content(post, [])) do
      nil     -> []
      results -> results
                 |> Enum.map(&(String.downcase(&1)))
                 |> Enum.uniq
    end
  end

  defp coordinates(%{location_lat: nil, location_long: nil}), do: nil
  defp coordinates(%{location_lat: lat, location_long: long}), do: %{lat: lat, lon: long}

  defp detected_language(_post), do: "en"

  defp has_images(%{body: body, reposted_source: %{body: reposted_body}}) do
    Enum.any?(body ++ reposted_body, &(&1["kind" == "image"]))
  end
  defp has_images(%{body: body}) do
    Enum.any?(body, &(&1["kind"] == "image"))
  end
end
