defmodule Ello.Search.UsersIndexTest do
  use Ello.Search.Case
  alias Ello.Search.UsersIndex
  alias Ello.Core.{Repo, Factory, Network}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    current_user = Factory.insert(:user)
    user        = Factory.insert(:user)
    lana32d      = Factory.insert(:user, %{id: 1, username: "lanakane32d"})
    lanakane     = Factory.insert(:user, %{id: 2, username: "lanakane"})
    lanabandero  = Factory.insert(:user, %{id: 3, username: "lana-bandero"})
    locked_user = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    spam_user   = Factory.insert(:user)
    nsfw_user   = Factory.insert(:user, settings: %{posts_adult_content: true})
    nudity_user = Factory.insert(:user, settings: %{posts_nudity: true})

    elastic_url = "http://192.168.99.100:9200"
    index_name  = "users"
    doc_type    = "user"
    lana32d_data  = %{
      id:         lana32d.id,
      username:   lana32d.username,
      raw_username: lana32d.username,
      short_bio:  lana32d.short_bio,
      links:      lana32d.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  lana32d.locked_at,
      created_at: lana32d.created_at,
      updated_at: lana32d.updated_at
    }
    lanakane_data  = %{
      id:         lanakane.id,
      username:   lanakane.username,
      raw_username: lanakane.username,
      short_bio:  lanakane.short_bio,
      links:      lanakane.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  lanakane.locked_at,
      created_at: lanakane.created_at,
      updated_at: lanakane.updated_at
    }
    lanabandero_data  = %{
      id:         lanabandero.id,
      username:   lanabandero.username,
      raw_username: lanabandero.username,
      short_bio:  lanabandero.short_bio,
      links:      lanabandero.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  lanabandero.locked_at,
      created_at: lanabandero.created_at,
      updated_at: lanabandero.updated_at
    }
    index_data  = %{
      id:         user.id,
      username:   user.username,
      raw_username: user.username,
      short_bio:  user.short_bio,
      links:      user.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  user.locked_at,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
    locked_index_data = %{
      id:         locked_user.id,
      username:   locked_user.username,
      raw_username: locked_user.username,
      short_bio:  locked_user.short_bio,
      links:      locked_user.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  locked_user.locked_at,
      created_at: locked_user.created_at,
      updated_at: locked_user.updated_at
    }
    spam_index_data = %{
      id:         spam_user.id,
      username:   spam_user.username,
      raw_username: spam_user.username,
      short_bio:  spam_user.short_bio,
      links:      spam_user.links,
      is_spammer: true,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  spam_user.locked_at,
      created_at: spam_user.created_at,
      updated_at: spam_user.updated_at
    }
    nsfw_index_data = %{
      id:         nsfw_user.id,
      username:   nsfw_user.username,
      raw_username: nsfw_user.username,
      short_bio:  nsfw_user.short_bio,
      links:      nsfw_user.links,
      is_spammer: false,
      is_nsfw_user: nsfw_user.settings.posts_adult_content,
      posts_nudity: false,
      locked_at:  nsfw_user.locked_at,
      created_at: nsfw_user.created_at,
      updated_at: nsfw_user.updated_at
    }
    nudity_index_data = %{
      id:         nudity_user.id,
      username:   nudity_user.username,
      raw_username: nudity_user.username,
      short_bio:  nudity_user.short_bio,
      links:      nudity_user.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: nudity_user.settings.posts_nudity,
      locked_at:  nudity_user.locked_at,
      created_at: nudity_user.created_at,
      updated_at: nudity_user.updated_at
    }
    mapping = %{
      properties: %{
        id:         %{type: "text"},
        username:   %{type: "text", analyzer: "username_autocomplete"},
        raw_username: %{type: "text", index: false},
        short_bio:  %{type: "text"},
        links:      %{type: "text"},
        is_spammer: %{type: "boolean"},
        is_nsfw_user: %{type: "boolean"},
        posts_nudity: %{type: "boolean"},
        locked_at:  %{type: "date"},
        created_at: %{type: "date"},
        updated_at: %{type: "date"}
      }
    }

    Elastix.Index.delete(elastic_url, index_name)
    Elastix.Index.create(elastic_url, index_name, %{
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
        filter: [
          "lowercase",
          "autocomplete"
        ]
    }
    }
    }
    }
    })
    Elastix.Mapping.put(elastic_url, index_name, doc_type, mapping)
    Elastix.Document.index(elastic_url, index_name, doc_type, user.id, index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, locked_user.id, locked_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, spam_user.id, spam_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, nsfw_user.id, nsfw_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, nudity_user.id, nudity_index_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, lana32d.id, lana32d_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, lanakane.id, lanakane_data)
    Elastix.Document.index(elastic_url, index_name, doc_type, lanabandero.id, lanabandero_data)
    Elastix.Index.refresh(elastic_url, index_name)
    {:ok, user: user, locked_user: locked_user, spam_user: spam_user, nsfw_user: nsfw_user, nudity_user: nudity_user, current_user: current_user, lana32d: lana32d, lanakane: lanakane, lanabandero: lanabandero}
  end

  test "username_search - scores more exact matches higher", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert [to_string(context.user.id), to_string(context.spam_user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include locked users", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.locked_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes spamified users", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include nsfw users if client disallows nsfw", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.nsfw_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes nsfw users if client allows nsfw", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: true, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.nsfw_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include nudity users if client disallows nudity", context do
    response = UsersIndex.username_search(context.user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.nudity_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes nudity users if client allows nudity", context do
    response = UsersIndex.username_search(context.spam_user.username, %{current_user: context.current_user, allow_nsfw: false, allow_nudity: true})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.nudity_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.spam_user.id])

    response = UsersIndex.username_search("username", %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert [to_string(context.spam_user.id), to_string(context.user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    response = UsersIndex.username_search("username", %{current_user: current_user, allow_nsfw: false, allow_nudity: false})
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    response = UsersIndex.username_search("username", %{current_user: current_user, allow_nsfw: false, allow_nudity: false})
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - lana test", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.lana32d.id])

    response = UsersIndex.username_search("lana", %{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert response.status_code == 200
    assert to_string(context.lana32d.id) == hd(Enum.map(response.body["hits"]["hits"], &(&1["_id"])))
    assert to_string(context.lanakane.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.lanabandero.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end
end
