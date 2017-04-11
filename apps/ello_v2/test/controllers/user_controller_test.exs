defmodule Ello.V2.UserControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Redis

  setup %{conn: conn} do
    user = Factory.insert(:user)
    spying = Script.insert(:espionage_category)
    archer = Script.insert(:archer, category_ids: [spying.id])
    {:ok, conn: auth_conn(conn, user), unauth_conn: conn, archer: archer, user: user}
  end

  test "GET /v2/users/:id - without token", %{unauth_conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert conn.status == 401
  end

  test "GET /v2/users/:id - public token", %{unauth_conn: conn, archer: archer} do
    conn = conn
           |> public_conn
           |> get(user_path(conn, :show, archer))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/:id - user token", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/~:username - user token", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, "~#{archer.username}"))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/:id - 304", %{conn: conn, archer: archer} do
    resp = get(conn, user_path(conn, :show, archer))
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_path(conn, :show, archer))
    assert resp2.status == 304
    archer
    |> Ecto.Changeset.change(%{updated_at: DateTime.utc_now})
    |> Ello.Core.Repo.update!
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_path(conn, :show, archer))
    assert resp3.status == 200
  end

  @tag :json_schema
  test "GET /v2/users/:id - json schema", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert :ok = validate_json("user", json_response(conn, 200))
  end

  test "GET /v2/users/:id - when blocked", context do
    Redis.command(["SADD", "user:#{context.user.id}:block_id_cache", context.archer.id])

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404

    Redis.command(["SREM", "user:#{context.user.id}:block_id_cache", context.archer.id])
  end

  test "GET /v2/users/:id - when inverse blocked", context do
    Redis.command(["SADD", "user:#{context.user.id}:inverse_block_id_cache", context.archer.id])

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404

    Redis.command(["SREM", "user:#{context.user.id}:inverse_block_id_cache", context.archer.id])
  end

  test "GET /v2/users/:id - when locked", context do
    context.archer
    |> Ecto.Changeset.change(locked_at: DateTime.utc_now)
    |> Ello.Core.Repo.update!

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404
  end

  test "GET /v2/users/:id - public token, private user ", %{unauth_conn: conn, archer: archer} do
    archer
    |> Ecto.Changeset.change(is_public: false)
    |> Ello.Core.Repo.update!

    conn = conn
           |> public_conn
           |> get(user_path(conn, :show, archer))

    assert conn.status == 404
  end

  test "GET /v2/users/autocomplete - without token", %{unauth_conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :autocomplete, %{"username" => archer.username}))
    assert conn.status == 401
  end

  test "GET /v2/users/autocomplete - public token", %{unauth_conn: conn, archer: archer} do
    conn = conn
           |> public_conn
           |> get(user_path(conn, :autocomplete, %{"username" => archer.username}))
    assert conn.status == 401
  end

  test "GET /v2/users/autocomplete - user token", %{conn: conn, archer: archer} do
    index_name  = "users"
    doc_type    = "user"
    index_data  = %{
      id:         archer.id,
      username:   archer.username,
      raw_username: archer.username,
      short_bio:  archer.short_bio,
      links:      archer.links,
      is_spammer: false,
      is_nsfw_user: false,
      posts_nudity: false,
      locked_at:  archer.locked_at,
      created_at: archer.created_at,
      updated_at: archer.updated_at
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

    Client.delete_index(index_name)
    Client.create_index(index_name, %{
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
    Client.put_mapping(index_name, doc_type, mapping)
    Client.index_document(index_name, doc_type, archer.id, index_data)
    Client.refresh_index(index_name)
    conn = get(conn, user_path(conn, :autocomplete, %{"username" => archer.username}))
    assert conn.status == 200
    assert [%{"image_url" => "https://assets.ello.co/uploads/user/avatar/42/ello-small-fad52e18.png",
              "name" => "archer"}] = json_response(conn, 200)
  end

  test "GET /v2/users/autocomplete - user token with no search results", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :autocomplete, %{"username" => "asdf"}))
    assert conn.status == 204
  end
end
