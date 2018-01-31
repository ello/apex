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
  end

  test "Abbreviated post representation of a repost", %{user: user, post: post, repost: repost, reposter: reposter} do
    query = """
      query($username: String!, $token: String!) {
        post(username: $username, token: $token) {
          id
          token
          summary {
            link_url
            kind
            data
          }
          content {
            link_url
            kind
            data
          }
          reposted_source {
            id
            token
            summary {
              link_url
              kind
              data
            }
            content {
              link_url
              kind
              data
            }
            author {
              id
              username
            }
          }
        }
      }
    """

    resp = post_graphql(%{query: query, variables: %{username: reposter.username, token: repost.token}})
    assert %{"data" => %{"post" => json}} = json_response(resp)
    assert json["id"] == "#{repost.id}"
    assert hd(json["summary"])["kind"] == "text"
    assert hd(json["summary"])["data"] == "<p>Phrasing!</p>"
    assert json["reposted_source"]["id"] == "#{post.id}"
    assert json["reposted_source"]["author"]["id"] == "#{user.id}"
    assert hd(json["reposted_source"]["summary"])["data"] == "<p>Phrasing!</p>"
    assert hd(json["reposted_source"]["summary"])["kind"] == "text"
  end
end
