defmodule Ello.V3.Resolvers.UserPostStreamTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    user_no_posts = Factory.insert(:user)
    post = Factory.insert(:post, author: user)
    {:ok, %{user: user, post: post, user_no_posts: user_no_posts}}
  end

  test "Returns posts with username", context do
    query = """
    {
      userPostStream(username: "#{context.user.username}") {
        next
        posts {
          id
        }
      }
    }
    """
    resp = post_graphql(%{query: query})
    json = json_response(resp)
    assert to_string(context.post.id) == hd(json["data"]["userPostStream"]["posts"])["id"]
  end

  test "Returns posts if username starts with '~'", context do
    query = """
    {
      userPostStream(username: "~#{context.user.username}") {
        next
        posts {
          id
        }
      }
    }
    """
    resp = post_graphql(%{query: query})
    json = json_response(resp)
    assert to_string(context.post.id) == hd(json["data"]["userPostStream"]["posts"])["id"]
  end

  test "Returns error if username not found" do
    query = """
    {
      userPostStream(username: "asdf") {
        next
        posts {
          id
        }
      }
    }
    """
    resp = post_graphql(%{query: query})
    json = json_response(resp)
    assert hd(json["errors"])["message"] == "User not found"
  end

  test "User with no posts should return an empty list", context do
    query = """
    {
      userPostStream(username: "#{context.user_no_posts.username}") {
        next
        posts {
          id
        }
      }
    }
    """
    resp = post_graphql(%{query: query})
    json = json_response(resp)
    assert json["data"]["userPostStream"] == %{"next" => nil, "posts" => []}
  end
end
