defmodule Ello.V3.Resolvers.FindPostTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    post = Factory.insert(:post, author: user)
    reposter = Factory.insert(:user)
    repost = Factory.insert(:post, reposted_source: post, author: reposter)
    {:ok, %{user: user, post: post, repost: repost, reposter: reposter}}
  end

  test "Abbreviated post representation", %{user: user, post: post} do
    query = """
      query($username: String!, $token: String!) {
        post(username: $username, token: $token) {
          id
          token
          createdAt
          summary {
            link_url
            kind
            data
          }
        }
      }
    """

    resp = post_graphql(%{query: query, variables: %{username: user.username, token: post.token}})
    assert %{"data" => %{"post" => json}} = json_response(resp)
    assert json["id"] == "#{post.id}"
    assert json["token"] == "#{post.token}"
    assert json["createdAt"] == DateTime.to_iso8601(post.created_at)
    assert json["summary"] == post.rendered_summary
  end

  test "Full post representation with a repost", %{user: user, post: post, repost: repost, reposter: reposter} do
    query = """
      query($username: String!, $token: String!) {
        post(username: $username, token: $token) {
          id
          token
          createdAt
          author {
            id
            username
          }
          summary {
            linkUrl
            kind
            data
            links {
              assetId
            }
          }
          content {
            linkUrl
            kind
            data
            links {
              assetId
            }
          }
          postStats {
            lovesCount
            viewsCount
            commentsCount
            repostsCount
          }
          currentUserState {
            loved
            reposted
            watching
          }
          repostedSource {
            id
            token
            createdAt
            summary {
              linkUrl
              kind
              data
              links {
                assetId
              }
            }
            content {
              linkUrl
              kind
              data
              links {
                assetId
              }
            }
            author {
              id
              username
            }
            postStats {
              lovesCount
              viewsCount
              commentsCount
              repostsCount
            }
            currentUserState {
              loved
              reposted
              watching
            }
          }
        }
      }
    """

    resp = post_graphql(%{query: query, variables: %{username: reposter.username, token: repost.token}})
    assert %{"data" => %{"post" => json}} = json_response(resp)

    assert json["id"] == "#{repost.id}"
    assert json["author"]["id"] == "#{reposter.id}"
    assert hd(json["summary"])["kind"] == "text"
    assert hd(json["summary"])["data"] == "<p>Phrasing!</p>"
    assert json["postStats"]["lovesCount"] == 0
    assert json["postStats"]["viewsCount"] == 0
    assert json["postStats"]["commentsCount"] == 0
    assert json["postStats"]["repostsCount"] == 0
    assert json["currentUserState"]["reposted"] == false
    assert json["currentUserState"]["loved"] == false
    assert json["currentUserState"]["watching"] == false

    assert json["repostedSource"]["id"] == "#{post.id}"
    assert json["repostedSource"]["author"]["id"] == "#{user.id}"
    assert hd(json["repostedSource"]["summary"])["data"] == "<p>Phrasing!</p>"
    assert hd(json["repostedSource"]["summary"])["kind"] == "text"
    assert json["repostedSource"]["postStats"]["lovesCount"] == 0
    assert json["repostedSource"]["postStats"]["viewsCount"] == 0
    assert json["repostedSource"]["postStats"]["commentsCount"] == 0
    assert json["repostedSource"]["postStats"]["repostsCount"] == 0
    assert json["repostedSource"]["currentUserState"]["reposted"] == false
    assert json["repostedSource"]["currentUserState"]["loved"] == false
    assert json["repostedSource"]["currentUserState"]["watching"] == false
  end
end
