defmodule Ello.V3.Resolvers.UserPostStreamTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    user_no_posts = Factory.insert(:user)
    post = Factory.insert(:post, author: user)
    {:ok, %{user: user, post: post, user_no_posts: user_no_posts}}
  end

  @query """
    query($username: String!) {
      userPostStream(username: $username) {
        next
        posts {
          id
        }
      }
    }
  """

  test "Returns posts with username", context do
    resp = post_graphql(%{query: @query, variables: %{username: context.user.username}})
    json = json_response(resp)
    assert to_string(context.post.id) == hd(json["data"]["userPostStream"]["posts"])["id"]
  end

  test "Returns posts if username starts with '~'", context do
    resp = post_graphql(%{query: @query, variables: %{username: "~#{context.user.username}"}})
    json = json_response(resp)
    assert to_string(context.post.id) == hd(json["data"]["userPostStream"]["posts"])["id"]
  end

  test "Returns error if username not found" do
    resp = post_graphql(%{query: @query, variables: %{username: "asdf"}})
    json = json_response(resp)
    assert hd(json["errors"])["message"] == "User not found"
  end

  test "User with no posts should return an empty list", context do
    resp = post_graphql(%{query: @query, variables: %{username: context.user_no_posts.username}})
    json = json_response(resp)
    assert json["data"]["userPostStream"] == %{"next" => nil, "posts" => []}
  end

  test "Returns all required author data for iOS", context do
    query = """
    {
      userPostStream(username: "#{context.user.username}") {
        next
        posts {
          id
          author {
            id
            username
            name
            location
            formatted_short_bio
            badges
            current_user_state {
              relationship_priority
            }
            external_links_list {
              icon
              type
              url
              text
            }
            user_stats {
              loves_count
              followers_count
              following_count
              posts_count
              total_views_count
            }
            settings {
              posts_adult_content
              has_commenting_enabled
              has_reposting_enabled
              has_sharing_enabled
              has_loves_enabled
              is_collaborateable
              is_hireable
            }
            avatar {
              original {
                url
              }
              large {
                metadata {
                  width
                  height
                  size
                  type
                }
                url
              }
            }
            cover_image {
              original {
                url
              }
              hdpi {
                metadata {
                  width
                  height
                  size
                  type
                }
                url
              }
            }
          }
        }
      }
    }
    """
    resp = post_graphql(%{query: query})
    json = json_response(resp)
    author = hd(json["data"]["userPostStream"]["posts"])["author"]
    author_keys = Map.keys(author)
    settings_keys = Map.keys(author["settings"])
    assert "id" in author_keys
    assert "username" in author_keys
    assert "name" in author_keys
    assert "avatar" in author_keys
    assert "cover_image" in author_keys
    assert "posts_adult_content" in settings_keys
    assert "has_commenting_enabled" in settings_keys
    assert "has_reposting_enabled" in settings_keys
    assert "has_sharing_enabled" in settings_keys
    assert "has_loves_enabled" in settings_keys
    assert "is_collaborateable" in settings_keys
    assert "is_hireable" in settings_keys
  end
end
