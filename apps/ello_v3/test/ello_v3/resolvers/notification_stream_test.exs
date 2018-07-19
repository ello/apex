defmodule Ello.V3.Resolvers.NotificationStreamTest do
  use Ello.V3.Case, async: false
  alias Ello.Notifications.Stream

  setup do
    # Test against real service
    # Application.put_env(:ello_notifications, :stream_client, Stream.Client.HTTP)
    # on_exit fn() ->
    #   Application.put_env(:ello_notifications, :stream_client, Stream.Client.Test)
    # end

    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start()
    Stream.Client.Test.reset()

    user = Factory.insert(:user)
    user_post = Factory.insert(:post, author: user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, author: author)
    category = Factory.insert(:category, level: "primary", order: "5")

    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: post.id,
      subject_type: "Post",
      kind: "post_mention_notification",
      created_at: DateTime.from_unix!(1000),
      originating_user_id: author.id,
    })

    love = Factory.insert(:love, post: user_post)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: love.id,
      subject_type: "Love",
      kind: "love_on_original_post_notification",
      created_at: DateTime.from_unix!(2000),
      originating_user_id: love.user_id,
    })

    repost = Factory.insert(:post, reposted_source: post)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: repost.id,
      subject_type: "Post",
      kind: "repost_notification",
      created_at: DateTime.from_unix!(3000),
      originating_user_id: repost.author_id,
    })

    repost_love = Factory.insert(:love, post: repost)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: repost_love.id,
      subject_type: "Love",
      kind: "love_on_repost_notification",
      created_at: DateTime.from_unix!(4000),
      originating_user_id: repost_love.user_id,
    })

    category_post = Factory.insert(:category_post, %{
      post: user_post,
      featured_by: author,
      category: category,
    })
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: category_post.id,
      subject_type: "CategoryPost",
      kind: "category_post_featured",
      created_at: DateTime.from_unix!(5000),
      originating_user_id: category_post.featured_by_id,
    })

    artist_invite_submission = Factory.insert(:artist_invite_submission, post: user_post)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: artist_invite_submission.id,
      subject_type: "ArtistInviteSubmission",
      kind: "approved_artist_invite_submission",
      created_at: DateTime.from_unix!(6000),
      originating_user_id: user.id,
    })

    comment = Factory.insert(:comment, parent_post: user_post)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: comment.id,
      subject_type: "Post",
      kind: "comment_notification",
      created_at: DateTime.from_unix!(7000),
      originating_user_id: comment.author_id,
    })

    comment = Factory.insert(:comment, parent_post: repost)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: comment.id,
      subject_type: "Post",
      kind: "comment_on_repost_notification",
      created_at: DateTime.from_unix!(8000),
      originating_user_id: comment.author_id,
    })

    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: author.id,
      subject_type: "User",
      kind: "new_follower_post", # legacy name
      created_at: DateTime.from_unix!(9000),
      originating_user_id: author.id,
    })

    category_user = Factory.insert(:category_user, user: user, featured_by: Factory.insert(:user))
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: category_user.id,
      subject_type: "CategoryUser",
      kind: "user_added_as_featured_notification",
      created_at: DateTime.from_unix!(10_000),
      originating_user_id: category_user.featured_by_id,
    })


    watch = Factory.insert(:watch, post: post)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: watch.id,
      subject_type: "Watch",
      kind: "watch_notification",
      created_at: DateTime.from_unix!(11_000),
      originating_user_id: watch.user_id,
    })

    {:ok, %{
      user: user,
    }}
  end

  @basic_query """
    query($perPage: Int, $before: String, $category: NotificationCategory) {
      notificationStream(perPage: $perPage, before: $before, category: $category) {
        isLastPage
        next
        notifications { kind subjectId subjectType createdAt }
      }
    }
  """

  @full_query """
    fragment imageVersionProps on Image {
      url
      metadata { height width type size }
    }

    fragment responsiveImageVersions on ResponsiveImageVersions {
      xhdpi { ...imageVersionProps }
      hdpi { ...imageVersionProps }
      mdpi { ...imageVersionProps }
      ldpi { ...imageVersionProps }
      optimized { ...imageVersionProps }
      original { ...imageVersionProps }
      video { ...imageVersionProps }
    }

    fragment avatarImageVersion on TshirtImageVersions {
      small { ...imageVersionProps }
      regular { ...imageVersionProps }
      large { ...imageVersionProps }
      original { ...imageVersionProps }
    }

    fragment authorSummary on User {
      id
      username
      name
      currentUserState { relationshipPriority }
      avatar { ...avatarImageVersion }
    }

    fragment contentProps on ContentBlocks {
      linkUrl
      kind
      data
      links { assets }
    }

    fragment postSummary on Post {
      id
      token
      createdAt
      summary { ...contentProps }
      author { ...authorSummary }
      assets { id attachment { ...responsiveImageVersions } }
      postStats { lovesCount commentsCount viewsCount repostsCount }
      currentUserState { watching loved reposted }
    }

    fragment commentSummary on Comment {
      id
      createdAt
      author { ...authorSummary }
      summary { ...contentProps }
      content { ...contentProps }
      assets { id attachment { ...responsiveImageVersions } }
      parentPost { ...postSummary }
    }

    fragment categorySummary on Category {
      id slug name
    }

    fragment categoryPostSummary on CategoryPost {
      id
      status
      category { ...categorySummary }
      post { ...postSummary repostedSource { ...postSummary } }
      featuredBy { ...authorSummary }
    }

    fragment categoryUserSummary on CategoryUser {
      id
      role
      category { ...categorySummary }
      user { ...authorSummary }
    }

    fragment artistInviteSubmissionSummary on ArtistInviteSubmission {
      id
      status
      post { ...postSummary repostedSource { ...postSummary } }
      artistInvite { id title slug }
    }

    fragment loveSummary on Love {
      id
      post { ...postSummary repostedSource { ...postSummary } }
      user { ...authorSummary }
    }

    fragment watchSummary on Watch {
      id
      post { ...postSummary repostedSource { ...postSummary } }
    }

    query($perPage: Int, $before: String, $category: NotificationCategory) {
      notificationStream(perPage: $perPage, before: $before, category: $category) {
        isLastPage
        next
        notifications {
          id
          kind
          subjectType
          createdAt
          originatingUser { ...authorSummary }
          subject {
            __typename
            ... on Post { ...postSummary repostedSource { ...postSummary } }
            ... on Comment { ...commentSummary parentPost { ...postSummary } }
            ... on User { ...authorSummary }
            ... on CategoryUser { ...categoryUserSummary }
            ... on CategoryPost { ...categoryPostSummary }
            ... on Love { ...loveSummary }
            ... on ArtistInviteSubmission { ...artistInviteSubmissionSummary }
            ... on Watch { ...watchSummary }
          }
        }
      }
    }
  """

  test "getting paginated notifications - no subjects", %{
    user: user,
  } do
    resp = post_graphql(%{query: @basic_query, variables: %{perPage: 2}}, user)
    assert %{"data" => %{"notificationStream" => json}} = json_response(resp)
    assert %{"notifications" => notifications, "isLastPage" => false, "next" => next} = json
    assert [_n1, n2] = notifications
    assert n2["kind"]
    assert n2["subjectType"]
    assert n2["createdAt"] == next

    resp2 = post_graphql(%{query: @basic_query, variables: %{
      perPage: 20,
      before: next
    }}, user)
    assert %{"data" => %{"notificationStream" => json2}} = json_response(resp2)
    assert %{"notifications" => notifications2, "isLastPage" => true, "next" => _} = json2
    assert length(notifications2) == 9
  end

  test "getting notifications with subjects", %{
    user: user,
  } do
    resp = post_graphql(%{query: @full_query, variables: %{perPage: 25}}, user)
    assert %{"data" => %{"notificationStream" => json}} = json_response(resp)
    assert %{"notifications" => notifications, "isLastPage" => true, "next" => _next} = json
    assert length(notifications) == 11
    assert [n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10] = notifications

    assert n0["id"]
    assert n0["subjectType"] == "Watch"
    assert n0["subject"]["id"]
    assert n0["subject"]["post"]["token"]
    assert n0["subject"]["post"]["author"]["username"]
    assert n0["originatingUser"]["username"]

    assert n1["id"]
    assert n1["subjectType"] == "CategoryUser"
    assert n1["subject"]["id"]
    assert n1["subject"]["role"]
    assert n1["subject"]["category"]["name"]
    assert n1["originatingUser"]["username"]

    assert n2["subjectType"] == "User"
    assert n2["subject"]["id"]
    assert n2["subject"]["username"]
    assert n2["originatingUser"]["username"]

    assert n3["kind"] == "comment_on_repost_notification"
    assert n3["subjectType"] == "Post"
    assert n3["subject"]["__typename"] == "Comment"
    assert n3["subject"]["id"]
    assert n3["subject"]["content"]
    assert n3["subject"]["parentPost"]["id"]
    assert n3["subject"]["parentPost"]["token"]
    assert n3["subject"]["parentPost"]["author"]["id"]
    assert n3["subject"]["parentPost"]["author"]["username"]
    assert n3["originatingUser"]["username"]

    assert n4["kind"] == "comment_notification"
    assert n4["subjectType"] == "Post"
    assert n3["subject"]["__typename"] == "Comment"
    assert n4["subject"]["id"]
    assert n4["subject"]["content"]
    assert n4["subject"]["parentPost"]["id"]
    assert n4["subject"]["parentPost"]["token"]
    assert n4["subject"]["parentPost"]["author"]["id"]
    assert n4["subject"]["parentPost"]["author"]["username"]
    assert n4["originatingUser"]["username"]

    assert n5["subjectType"] == "ArtistInviteSubmission"
    assert n5["subject"]["id"]
    assert n5["subject"]["artistInvite"]["id"]
    assert n5["subject"]["artistInvite"]["title"]
    assert n5["originatingUser"]["username"]

    assert n6["subjectType"] == "CategoryPost"
    assert n6["subject"]["id"]
    assert n6["subject"]["category"]["name"]
    assert n6["subject"]["featuredBy"]["username"]
    assert n6["originatingUser"]["username"]

    assert n7["subjectType"] == "Love"
    assert n7["subject"]["id"]
    assert n7["subject"]["post"]["id"]
    assert n7["subject"]["post"]["token"]
    assert n7["subject"]["post"]["author"]
    assert n7["subject"]["post"]["author"]["username"]
    assert n7["originatingUser"]["username"]

    assert n8["subjectType"] == "Post"
    assert n8["subject"]["id"]
    assert n8["subject"]["token"]
    assert n8["subject"]["author"]
    assert n8["subject"]["author"]["username"]
    assert n8["originatingUser"]["username"]

    assert n9["subjectType"] == "Love"
    assert n9["subject"]["id"]
    assert n9["subject"]["post"]["id"]
    assert n9["subject"]["post"]["token"]
    assert n9["subject"]["post"]["author"]
    assert n9["subject"]["post"]["author"]["username"]
    assert n9["originatingUser"]["username"]

    assert n10["subjectType"] == "Post"
    assert n10["subject"]["id"]
    assert n10["subject"]["id"]
    assert n10["subject"]["token"]
    assert n10["subject"]["author"]
    assert n10["subject"]["author"]["username"]
    assert n10["originatingUser"]["username"]
  end
end
