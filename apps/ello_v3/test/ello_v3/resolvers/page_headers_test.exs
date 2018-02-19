defmodule Ello.V3.Resolvers.PageHeadersTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user = Factory.insert(:user)
    {:ok, %{user: user}}
  end

  @full_query """
    fragment imageVersionProps on Image {
      url
      metadata { height width type size }
    }

    fragment avatarImageVersion on TshirtImageVersions {
      small { ...imageVersionProps }
      regular { ...imageVersionProps }
      large { ...imageVersionProps }
      original { ...imageVersionProps }
    }

    fragment pageHeaderImageVersions on ResponsiveImageVersions {
      hdpi { ...imageVersionProps }
      xhdpi { ...imageVersionProps }
      optimized { ...imageVersionProps }
      original { ...imageVersionProps }
    }

    query($slug: String, $kind: PageHeaderKind!) {
      pageHeaders(slug: $slug, kind: $kind) {
        id
        postToken
        kind
        slug
        header
        subheader
        image { ...pageHeaderImageVersions }
        ctaLink { text url }
        user {
          username
          avatar { ...avatarImageVersion }
        }
      }
    }
  """

  @query """
    query($slug: String, $kind: PageHeaderKind!) {
      pageHeaders(slug: $slug, kind: $kind) {
        id
        header
        subheader
        kind
        slug
      }
    }
  """

  test "Full Page Header Representation - category promo", %{} do
    cat1 = Factory.insert(:category, %{
      slug: "cat1",
      promotionals: [],
      name: "Category 1",
      description: "a category",
      cta_href: "https://ello.co/",
      cta_caption: "Click HERE!",
    })
    user = Factory.insert(:user, username: "ello")
    promo = Factory.insert(:promotional, category: cat1, post_token: "foo", user: user)

    resp = post_graphql(%{query: @full_query, variables: %{slug: "cat1", kind: "CATEGORY"}})
    assert %{"data" => %{"pageHeaders" => [json | _]}} = json_response(resp)
    assert json["id"] == "#{promo.id}"
    assert json["postToken"] == "foo"
    assert json["header"] == "Category 1"
    assert json["kind"] == "CATEGORY"
    assert json["slug"] == "cat1"
    assert json["subheader"] == "a category"
    assert json["ctaLink"]["text"] == "Click HERE!"
    assert json["ctaLink"]["url"] == "https://ello.co/"
    assert json["user"]["username"] == "ello"
    assert json["image"]
  end

  test "Full Page Header Representation - page promo", %{} do
    user = Factory.insert(:user, username: "ello")
    promo = Factory.insert(:page_promotional, %{
      is_editorial: true,
      cta_href: "https://ello.co/",
      cta_caption: "Click HERE!",
      user: user,
    })
    resp = post_graphql(%{query: @full_query, variables: %{kind: "EDITORIAL"}})
    assert %{"data" => %{"pageHeaders" => [json | _]}} = json_response(resp)
    assert json["id"] == "#{promo.id}"
    assert json["postToken"] == "abc-123"
    assert json["kind"] == "EDITORIAL"
    refute json["slug"]
    assert json["header"] == "Header"
    assert json["subheader"] == "Sub Header"
    assert json["ctaLink"]["text"] == "Click HERE!"
    assert json["ctaLink"]["url"] == "https://ello.co/"
    assert json["user"]["username"] == "ello"
    assert %{} = json["user"]["avatar"]
    assert json["image"]
  end

  test "Get all headers for category", %{} do
    cat1 = Factory.insert(:category, slug: "cat1", promotionals: [])
    Factory.insert_list(3, :promotional, category: cat1)
    cat2 = Factory.insert(:category, slug: "cat2", promotionals: [])
    Factory.insert_list(3, :promotional, category: cat2)

    resp = post_graphql(%{query: @query, variables: %{slug: "cat1", kind: "CATEGORY"}})
    assert %{"data" => %{"pageHeaders" => [_p1, _p2, _p3]}} = json_response(resp)
  end

  test "Get all headers for artist invites", %{user: user} do
    Factory.insert_list(4, :page_promotional, is_artist_invite: true, is_logged_in: true)
    Factory.insert(:page_promotional, is_editorial: true, is_logged_in: true)
    Factory.insert(:page_promotional, is_artist_invite: true, is_logged_in: false)
    resp = post_graphql(%{query: @query, variables: %{kind: "ARTIST_INVITE"}}, user)
    assert %{"data" => %{"pageHeaders" => [_p1, _p2, _p3, _p4, _p5]}} = json_response(resp)
  end

  test "Get all headers for editorials", %{user: user} do
    Factory.insert_list(4, :page_promotional, is_editorial: true, is_logged_in: true)
    Factory.insert(:page_promotional, is_editorial: true, is_logged_in: false)
    Factory.insert(:page_promotional, is_artist_invite: true, is_logged_in: true)
    resp = post_graphql(%{query: @query, variables: %{kind: "EDITORIAL"}}, user)
    assert %{"data" => %{"pageHeaders" => [_p1, _p2, _p3, _p4, _p5]}} = json_response(resp)
  end

  test "Get all headers for all/subscribed - logged in", %{user: user} do
    Factory.insert_list(4, :page_promotional, is_logged_in: true)
    resp = post_graphql(%{query: @query, variables: %{kind: "GENERIC"}}, user)
    assert %{"data" => %{"pageHeaders" => [_p1, _p2, _p3, _p4]}} = json_response(resp)
  end

  test "Get all headers for all/subscribed - logged out", %{} do
    Factory.insert_list(4, :page_promotional, is_logged_in: false)
    Factory.insert(:page_promotional, is_editorial: true, is_logged_in: true)
    Factory.insert(:page_promotional, is_artist_invite: true, is_logged_in: false)
    Factory.insert(:page_promotional, is_logged_in: true)
    resp = post_graphql(%{query: @query, variables: %{kind: "GENERIC"}})
    assert %{"data" => %{"pageHeaders" => [_p1, _p2, _p3, _p4]}} = json_response(resp)
  end
end
