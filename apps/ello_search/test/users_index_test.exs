defmodule Ello.Search.UsersIndexTest do
  use Ello.Search.Case
  alias Ello.Search.UsersIndex
  alias Ello.Core.{Repo, Factory}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user        = Factory.insert(:user)
    locked_user = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    elastic_url = "http://192.168.99.100:9200"
    index_name  = "test_users"
    doc_type    = "user"
    index_data  = %{
      id:         user.id,
      username:   user.username,
      short_bio:  user.short_bio,
      links:      user.links,
      locked_at:  user.locked_at,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
    locked_index_data  = %{
      id:         locked_user.id,
      username:   locked_user.username,
      short_bio:  locked_user.short_bio,
      links:      locked_user.links,
      locked_at:  locked_user.locked_at,
      created_at: locked_user.created_at,
      updated_at: locked_user.updated_at
    }
    mapping = %{
      properties: %{
        id:         %{type: "text"},
        username:   %{type: "text"},
        short_bio:  %{type: "text"},
        links:      %{type: "text"},
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
    Elastix.Index.refresh(elastic_url, index_name)
    {:ok, user: user, locked_user: locked_user}
  end

  test "username_search - searches successfully", context do
    response = UsersIndex.username_search(context.user.username)
    assert response.status_code == 200
    assert [to_string(context.user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include locked users", context do
    response = UsersIndex.username_search(context.user.username)
    assert response.status_code == 200
    assert [to_string(context.user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute [to_string(context.locked_user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end
end
