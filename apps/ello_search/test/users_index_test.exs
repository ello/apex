defmodule Ello.Search.UsersIndexTest do
  use Ello.Search.Case
  alias Ello.Search.UsersIndex
  alias Ello.Core.{Repo, Factory}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user        = Factory.insert(:user)
    elastic_url = "http://192.168.99.100:9200"
    index_name  = "test_users"
    doc_type    = "user"
    index_data  = %{
      id:         user.id,
      username:   user.username,
      short_bio:  user.short_bio,
      links:      user.links,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
    mapping = %{
      properties: %{
        id:         %{type: "text"},
        username:   %{type: "text"},
        short_bio:  %{type: "text"},
        links:      %{type: "text"},
        created_at: %{type: "date"},
        updated_at: %{type: "date"}
      }
    }

    Elastix.Index.delete(elastic_url, index_name)
    Elastix.Index.create(elastic_url, index_name, %{})
    Elastix.Mapping.put(elastic_url, index_name, doc_type, mapping)
    Elastix.Document.index(elastic_url, index_name, doc_type, user.id, index_data)
    Elastix.Index.refresh(elastic_url, index_name)
    {:ok, user: user}
  end

  test "username_search", context do
    response = UsersIndex.username_search(context.user.username)
    assert response.status_code == 200
    assert [to_string(context.user.id)] == Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end
end
