defmodule Ello.Search.UsersIndexTest do
  use Ello.Search.Case
  alias Ello.Search.UsersIndex
  alias Ello.Core.{Repo, Factory}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user        = Factory.insert(:user)
    locked_user = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    spam_user   = Factory.insert(:user)
    nsfw_user   = Factory.insert(:user, settings: %{posts_adult_content: true})
    elastic_url = "http://192.168.99.100:9200"
    index_name  = "test_users"
    doc_type    = "user"
    index_data  = %{
      id:         user.id,
      username:   user.username,
      short_bio:  user.short_bio,
      links:      user.links,
      is_spammer: false,
      is_nsfw_user: false,
      locked_at:  user.locked_at,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
    locked_index_data = %{
      id:         locked_user.id,
      username:   locked_user.username,
      short_bio:  locked_user.short_bio,
      links:      locked_user.links,
      is_spammer: false,
      is_nsfw_user: false,
      locked_at:  locked_user.locked_at,
      created_at: locked_user.created_at,
      updated_at: locked_user.updated_at
    }
    spam_index_data = %{
      id:         spam_user.id,
      username:   spam_user.username,
      short_bio:  spam_user.short_bio,
      links:      spam_user.links,
      is_spammer: true,
      is_nsfw_user: false,
      locked_at:  spam_user.locked_at,
      created_at: spam_user.created_at,
      updated_at: spam_user.updated_at
    }
    nsfw_index_data = %{
      id:         nsfw_user.id,
      username:   nsfw_user.username,
      short_bio:  nsfw_user.short_bio,
      links:      nsfw_user.links,
      is_spammer: false,
      is_nsfw_user: nsfw_user.settings.posts_adult_content,
      locked_at:  nsfw_user.locked_at,
      created_at: nsfw_user.created_at,
      updated_at: nsfw_user.updated_at
    }
    mapping = %{
      properties: %{
        id:         %{type: "text"},
        username:   %{type: "text"},
        short_bio:  %{type: "text"},
        links:      %{type: "text"},
        is_spammer: %{type: "boolean"},
        is_nsfw_user: %{type: "boolean"},
        locked_at:  %{type: "date"},
        created_at: %{type: "date"},
        updated_at: %{type: "date"}
      }
    }

    Elastix.Index.delete(elastic_url, index_name)
    Elastix.Index.create(elastic_url, index_name, %{})
    Elastix.Mapping.put(elastic_url, index_name, doc_type, mapping)
    Elastix.Document.index(elastic_url, index_name, doc_type, user.id, index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, locked_user.id, locked_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, spam_user.id, spam_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, nsfw_user.id, nsfw_index_data)
    Elastix.Index.refresh(elastic_url, index_name)
    {:ok, user: user, locked_user: locked_user, spam_user: spam_user, nsfw_user: nsfw_user}
  end

  test "username_search - searches successfully", context do
    response = UsersIndex.username_search(context.user.username, %{allow_nsfw: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include locked users", context do
    response = UsersIndex.username_search(context.user.username, %{allow_nsfw: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.locked_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include spamified users", context do
    response = UsersIndex.username_search(context.user.username, %{allow_nsfw: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include nsfw users if client settings do not allow", context do
    response = UsersIndex.username_search(context.user.username, %{allow_nsfw: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.nsfw_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes nsfw users if client settings allow nsfw", context do
    response = UsersIndex.username_search(context.user.username, %{allow_nsfw: true})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.nsfw_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end
end
