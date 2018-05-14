defmodule Ello.V3.Resolvers.EditorialStreamTest do
  use Ello.V3.Case

  @summary_query """
    query($perPage: String, $before: String, $preview: Boolean) {
      editorialStream(before: $before, preview: $preview, perPage: $perPage) {
        next
        isLastPage
        editorials { id }
      }
    }
  """

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

    fragment editorialImageVersions on ResponsiveImageVersions {
      ldpi { ...imageVersionProps }
      mdpi { ...imageVersionProps }
      hdpi { ...imageVersionProps }
      xhdpi { ...imageVersionProps }
      original { ...imageVersionProps }
    }

    fragment editorial on Editorial {
      id
      kind
      title
      subtitle
      url
      path
      one_by_one_image { ...editorialImageVersions }
      one_by_two_image { ...editorialImageVersions }
      two_by_one_image { ...editorialImageVersions }
      two_by_two_image { ...editorialImageVersions }
      stream { query tokens }
      post {
        id
        author { id }
        assets { id }
        postStats { lovesCount }
        currentUserState { watching }
        artistInviteSubmission { id artistInvite { id } }
        categoryPosts { id category { id } }
        repostedSource {
          id
          author { id }
          assets { id }
          postStats { lovesCount }
          currentUserState { watching }
          artistInviteSubmission { id artistInvite { id } }
          categoryPosts { id category { id } }
        }
      }
    }

    query($perPage: String, $before: String, $preview: Boolean) {
      editorialStream(before: $before, preview: $preview, perPage: $perPage) {
        next
        isLastPage
        editorials { ...editorial }
      }
    }
  """

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})

    e1 = Factory.insert(:post_editorial, published_position: 1, preview_position: 1)
    e2 = Factory.insert(:post_editorial, published_position: nil, preview_position: 3)
    e3 = Factory.insert(:external_editorial, published_position: 2, preview_position: 2)
    e4 = Factory.insert(:internal_editorial, published_position: 3, preview_position: 4)
    e5 = Factory.insert(:curated_posts_editorial, published_position: 4, preview_position: 5)
    e6 = Factory.insert(:external_editorial, published_position: nil, preview_position: 6)
    e7 = Factory.insert(:curated_posts_editorial, published_position: 5, preview_position: 7)
    staff = Factory.insert(:user, is_staff: true)

    {:ok, %{
      staff: staff,
      editorials: [e1, e2, e3, e4, e5, e6, e7],
    }}
  end

  test "Published order - public user", %{
    editorials: [_e1, _e2, e3, e4, e5, _e6, e7],
  } do
    resp = post_graphql(%{query: @summary_query, variables: %{"perPage" => 4}})
    assert %{"data" => %{"editorialStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => "2", "editorials" => editorials} = json
    assert Enum.map(editorials, &(String.to_integer(&1["id"]))) ==
      [e7.id, e5.id, e4.id, e3.id]
  end

  test "Published order - public user - second page", %{
    editorials: [e1, _e2, _e3, _e4, _e5, _e6, _e7],
  } do
    resp = post_graphql(%{query: @summary_query, variables: %{"perPage" => 4, "before" => "2"}})
    assert %{"data" => %{"editorialStream" => json}} = json_response(resp)
    assert %{"isLastPage" => true, "next" => "1", "editorials" => editorials} = json
    assert Enum.map(editorials, &(String.to_integer(&1["id"]))) ==
      [e1.id]
  end

  test "Preview requested but published order given - public user", %{
    editorials: [_e1, _e2, e3, e4, e5, _e6, e7],
  } do
    resp = post_graphql(%{
      query: @summary_query,
      variables: %{"perPage" => 4, "preview" => true}
    })
    assert %{"data" => %{"editorialStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => "2", "editorials" => editorials} = json
    assert Enum.map(editorials, &(String.to_integer(&1["id"]))) ==
      [e7.id, e5.id, e4.id, e3.id]
  end

  test "Preview order given - staff user", %{
    staff: staff,
    editorials: [_e1, _e2, _e3, e4, e5, e6, e7],
  } do
    resp = post_graphql(%{
      query: @summary_query,
      variables: %{"perPage" => 4, "preview" => true}
    }, staff)
    assert %{"data" => %{"editorialStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "editorials" => editorials} = json
    assert next == "4"
    assert Enum.map(editorials, &(String.to_integer(&1["id"]))) ==
      [e7.id, e6.id, e5.id, e4.id]
  end

  test "Full editorial serialization", %{
    staff: staff,
    editorials: [_e1, e2, _e3, e4, _e5, e6, e7],
  } do
    resp = post_graphql(%{
      query: @full_query,
      variables: %{"preview" => true}
    }, staff)

    assert %{"data" => %{"editorialStream" => %{"editorials" => editorials}}} = json_response(resp)
    assert [je7, je6, _je5, je4, je2, _je3, _je1] = editorials

    assert je7["id"] == "#{e7.id}"
    assert je7["kind"] == "POST_STREAM"
    assert je7["title"] == "Curated Posts Editorial"
    refute je7["subtitle"]
    refute je7["url"]
    refute je7["path"]
    assert je7["stream"]["query"] == "findPosts"
    assert [_, _] = je7["stream"]["tokens"]
    assert je7["one_by_one_image"]["hdpi"]["url"]
    assert je7["one_by_two_image"]["hdpi"]["url"]
    assert je7["two_by_one_image"]["hdpi"]["url"]
    assert je7["two_by_two_image"]["hdpi"]["url"]

    assert je6["id"] == "#{e6.id}"
    assert je6["kind"] == "EXTERNAL"
    assert je6["title"] == "External Editorial"
    assert je6["subtitle"] == "<p>check <em>it</em> out</p>"
    assert je6["url"] == "https://ello.co/wtf"
    refute je6["path"]
    refute je6["posts"]
    assert je6["one_by_one_image"]["hdpi"]["url"]
    assert je6["one_by_two_image"]["hdpi"]["url"]
    assert je6["two_by_one_image"]["hdpi"]["url"]
    assert je6["two_by_two_image"]["hdpi"]["url"]

    assert je4["id"] == "#{e4.id}"
    assert je4["kind"] == "INTERNAL"
    assert je4["title"] == "Internal Editorial"
    assert je4["subtitle"] == "<p>check <em>it</em> out</p>"
    assert je4["path"] == "/discover/recent"
    refute je4["url"]
    refute je4["posts"]
    assert je4["one_by_one_image"]["hdpi"]["url"]
    assert je4["one_by_two_image"]["hdpi"]["url"]
    assert je4["two_by_one_image"]["hdpi"]["url"]
    assert je4["two_by_two_image"]["hdpi"]["url"]

    assert je2["id"] == "#{e2.id}"
    assert je2["kind"] == "POST"
    assert je2["title"] == "Post Editorial"
    assert je2["subtitle"] == "<p>check <em>it</em> out</p>"
    refute je2["url"]
    refute je2["path"]
    assert post = je2["post"]
    assert post["id"]
    assert post["author"]["id"]
    assert je2["one_by_one_image"]["hdpi"]["url"]
    assert je2["one_by_two_image"]["hdpi"]["url"]
    assert je2["two_by_one_image"]["hdpi"]["url"]
    assert je2["two_by_two_image"]["hdpi"]["url"]
  end
end
