defmodule Ello.Search.PostIndex do
  alias Ello.Search.Client

  def create do
    Client.create_index(index_name(), settings())
    Client.put_mapping(index_name(), author_doc_type(), author_mapping())
    Client.put_mapping(index_name(), post_doc_type(), post_mapping())
  end

  def add(post, overrides \\ %{}) do
    post_data = %{
      id:                post.id,
      created_at:        post.created_at,
      updated_at:        post.updated_at,
      token:             post.token,
      author_id:         post.author_id,
      text_content:      "",
      hashtags:          "",
      mentions:          "",
      detected_language: "",
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
      is_saleable:       post.is_saleable
    } |> Map.merge(overrides)

    author_data = %{
      id:               post.author.id,
      created_at:       post.author.created_at,
      updated_at:       post.author.updated_at,
      name:             post.author.name,
      username:         post.author.username,
      short_bio:        post.author.short_bio,
      links:            post.author.links,
      locked_out:       post.author.locked_at,
      post_count:       0,
      comment_count:    0,
      follower_count:   0,
      is_spammer:       false,
      is_system_user:   post.author.is_system_user,
      is_featured_user: Enum.any(post.author.category_ids),
      has_avatar:       !!post.author.avatar,
      is_public:        post.author.is_public,
      category_ids:     post.author.category_ids,
      category_names:   post.author.category_names
    }

    Client.index_document(index_name(), author_doc_type(), post.author.id, author_data)
    Client.index_document(index_name(), post_doc_type(), post.id, post_data)
    Client.refresh_index(index_name())
  end

  def delete, do: Client.delete_index(index_name())

  def index_name,      do: "posts"
  def author_doc_type, do: "author"
  def post_doc_type,   do: "post"
  def doc_types,       do: [post_doc_type()]
  def settings,        do: %{}

  def author_mapping do
    %{
      properties: %{
        id:               %{type: "text"},
        created_at:       %{type: "date"},
        updated_at:       %{type: "date"},
        name:             %{type: "text"},
        username:         %{type: "text"},
        short_bio:        %{type: "text"},
        links:            %{type: "text"},
        locked_out:       %{type: "date"},
        post_count:       %{type: "integer"},
        comment_count:    %{type: "integer"},
        follower_count:   %{type: "integer"},
        is_spammer:       %{type: "boolean"},
        is_system_user:   %{type: "boolean"},
        is_featured_user: %{type: "boolean"},
        has_avatar:       %{type: "boolean"},
        is_public:        %{type: "boolean"},
        category_ids:     %{type: "text"},
        category_names:   %{type: "text"}
      }
    }
  end

  def post_mapping do
    %{
      "_parent" => %{type: author_doc_type},
      properties: %{
        id:                %{type: "integer"},
        created_at:        %{type: "date"},
        updated_at:        %{type: "date"},
        token:             %{type: "text"},
        author_id:         %{type: "integer"},
        text_content:      %{type: "text", analyzer: "english"},
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
        is_saleable:       %{type: "boolean"}
      }
    }
  end
end
