defmodule Ello.V2.PostViewControllerTest do
  use Ello.V2.ConnCase, async: false

  setup %{conn: conn} do
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post)
    post3 = Factory.insert(:post)
    post4 = Factory.insert(:post)
    user = Factory.insert(:user)

    # Stub redis in Ello.Events to instead send messages to the test process.
    pid = self()
    listener = &send(pid, &1)
    Application.put_env(:ello_events, :redis, listener)
    on_exit fn ->
      Application.delete_env(:ello_events, :redis)
    end

    {:ok, %{
      conn: conn,
      user_conn: user_conn(conn, user),
      user: user,
      posts: [post1, post2, post3, post4],
    }}
  end

  test "count post views correctly - via email with tokens", %{
    user: %{id: user_id, email: email},
    conn: conn,
    posts: posts,
  } do
    tokens = Enum.map(posts, &(&1.token))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      email: email,
      post_tokens: tokens,
      kind: "email",
      id: "New on Ello",
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => ids,
      "user_id" => ^user_id,
      "stream_kind" => "email",
      "stream_id" => "New on Ello",
    }]} = Jason.decode!(json)
    assert ids == Enum.map(posts, &(&1.id))
  end

  test "count post views correctly - via email with ids", %{
    user: %{id: user_id, email: email},
    conn: conn,
    posts: posts,
  } do
    ids = Enum.map(posts, &(&1.id))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      email: email,
      post_ids: ids,
      kind: "email",
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => ids,
      "user_id" => ^user_id,
      "stream_kind" => "email",
    }]} = Jason.decode!(json)
    assert ids == Enum.map(posts, &(&1.id))
  end

  test "count post views correctly - via user_id with ids", %{
    user: %{id: user_id},
    conn: conn,
    posts: posts,
  } do
    ids = Enum.map(posts, &(&1.id))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      user_id: user_id,
      post_ids: ids,
      kind: "email_notification",
      id: "1234",
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => ids,
      "user_id" => ^user_id,
      "stream_kind" => "email_notification",
      "stream_id" => "1234",
    }]} = Jason.decode!(json)
    assert ids == Enum.map(posts, &(&1.id))
  end

  test "count post views correctly - via bearer token with ids", %{
    user: %{id: user_id},
    user_conn: conn,
    posts: posts,
  } do
    ids = Enum.map(posts, &(&1.id))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      post_ids: ids,
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => ids,
      "user_id" => ^user_id,
      "stream_kind" => "unknown_via_post_view_api",
      "stream_id" => "",
    }]} = Jason.decode!(json)
    assert ids == Enum.map(posts, &(&1.id))
  end

  test "count post views correctly - via bearer token with string array of ids", %{
    user: %{id: user_id},
    user_conn: conn,
    posts: posts,
  } do
    ids = Enum.map(posts, &(&1.id))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      post_ids: Enum.join(ids, ","),
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => jids,
      "user_id" => ^user_id,
      "stream_kind" => "unknown_via_post_view_api",
      "stream_id" => "",
    }]} = Jason.decode!(json)
    assert jids == Enum.map(posts, &(&1.id))
  end

  test "count post views correctly - via bearer token with string array of tokens", %{
    user: %{id: user_id},
    user_conn: conn,
    posts: posts,
  } do
    tokens = Enum.map(posts, &(&1.token))
    assert %{status: 204} = get(conn, "/api/v2/post_views", %{
      posts: "[#{Enum.join(tokens, ",")}]",
    })
    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{
      "post_ids" => ids,
      "user_id" => ^user_id,
      "stream_kind" => "unknown_via_post_view_api",
      "stream_id" => "",
    }]} = Jason.decode!(json)
    assert ids == Enum.map(posts, &(&1.id))
  end
end
