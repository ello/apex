defmodule Ello.Core.Contest do
  import Ecto.Query
  alias Ello.Core.{
    Repo,
    Content,
    Network,
  }
  alias __MODULE__.{
    ArtistInvite,
    ArtistInviteSubmission,
    Preload,
  }
  alias Content.{
    Post,
    Love,
  }
  alias Network.Relationship

  def artist_invite(%{id_or_slug: id_or_slug, current_user: %{is_staff: true}} = options) do
    ArtistInvite
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end
  def artist_invite(%{id_or_slug: id_or_slug, current_user: %{id: current_user_id}} = options) do
    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user_id or ai.status != "preview")
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end
  def artist_invite(%{id_or_slug: id_or_slug} = options) do
    ArtistInvite
    |> where([ai], ai.status != "preview")
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end

  def artist_invites(%{page: page, per_page: per_page, preview: "true", current_user: %{is_staff: true}} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
  def artist_invites(%{page: page, per_page: per_page, preview: "true", current_user: %{id: current_user_id}} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user_id or ai.status != "preview")
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
  def artist_invites(%{for_discovery: true}) do
    ArtistInvite
    |> where([ai], ai.status == "open")
    |> Repo.all
  end
  def artist_invites(%{page: page, per_page: per_page} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> where([ai], ai.status != "preview")
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end

  def my_artist_invites(%{current_user: %{is_staff: true}} = options) do
    ArtistInvite
    |> order_by(desc: :created_at)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
  def my_artist_invites(%{current_user: %{id: current_user_id}} = options) do
    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user_id)
    |> order_by(desc: :created_at)
    |> Repo.all
    |> Preload.artist_invites(options)
  end

  def my_artist_invite(%{id_or_slug: id_or_slug, current_user: %{is_staff: true}} = options) do
    ArtistInvite
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end
  def my_artist_invite(%{id_or_slug: id_or_slug, current_user: %{id: current_user_id}} = options) do
    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user_id)
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end

  @doc """
  Return artist invite submissions for a given invite.
  """
  def artist_invite_submissions(%{
    status:       "declined",
    invite:       %{brand_account_id: user_id},
    current_user: %{id: user_id},
  } = options),
    do: get_submissions_by_status(options, "declined")
  def artist_invite_submissions(%{
    status:       "declined",
    current_user: %{is_staff: true},
  } = options),
    do: get_submissions_by_status(options, "declined")
  def artist_invite_submissions(%{
    status:       "unapproved",
    invite:       %{brand_account_id: user_id},
    current_user: %{id: user_id},
  } = options),
    do: get_submissions_by_status(options, "unapproved")
  def artist_invite_submissions(%{
    status:       "unapproved",
    current_user: %{is_staff: true},
  } = options),
    do: get_submissions_by_status(options, "unapproved")
  def artist_invite_submissions(%{
    status: "unapproved"
  }),
    do: []
  def artist_invite_submissions(%{
    status: "approved",
    invite: %{status: "open"},
  } = options),
    do: get_submissions_by_status(options, ["approved", "selected"])
  def artist_invite_submissions(%{
    status: "approved",
    invite: %{status: "closed"},
  } = options),
    do: get_submissions_by_status(options, "approved")
  def artist_invite_submissions(%{
    status: "selected",
    invite: %{status: "closed"},
  } = options),
    do: get_submissions_by_status(options, "selected")
  def artist_invite_submissions(%{
    status:       "selected",
    current_user: %{is_staff: true},
  } = options),
    do: get_submissions_by_status(options, "selected")
  def artist_invite_submissions(%{
    status:       "selected",
    invite:       %{brand_account_id: user_id},
    current_user: %{id: user_id}
  } = options),
    do: get_submissions_by_status(options, "selected")
  def artist_invite_submissions(%{ids: ids} = options) do
    ArtistInviteSubmission
    |> where([s], s.id in ^ids)
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
    |> filter_postless
  end
  def artist_invite_submissions(_),
    do: []

  defp get_submissions_by_status(options, status) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> by_status(status)
    |> filter_imageless(options)
    |> order_by([s], [desc: s.created_at])
    |> paginate_submissions(options)
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
    |> filter_postless
  end

  defp for_invite(query, %{invite: %{id: id}}),
    do: where(query, [s], s.artist_invite_id == ^id)

  defp by_status(query, status) when is_binary(status),
    do: where(query, [s], s.status == ^status)
  defp by_status(query, status) when is_list(status),
    do: where(query, [s], s.status in ^status)

  defp paginate_submissions(q, %{before: nil, per_page: per}), do: limit(q, ^per)
  defp paginate_submissions(query, %{before: before, per_page: per}) do
    {:ok, before, _} = before
                       |> URI.decode
                       |> DateTime.from_iso8601
    query
    |> where([s], s.created_at < ^before)
    |> limit(^per)
  end

  defp filter_postless(submissions) do
    Enum.reject(submissions, &(is_nil(&1.post)))
  end

  defp filter_imageless(query, %{images_only: false}), do: query
  defp filter_imageless(query, %{images_only: true}) do
    # In order to determine if a post has images we have to parse the body
    # To do so we use a lateral join with a subquery.
    # The subquery iterates over each post's body as a row and returns a simple
    # true value if the block is an image.
    # Next we use the where to filter out all submissions/posts where the subquery
    # did not find an image.
    # We then use group by to remove duplicates (due to multiple images)
    query
    |> join(:left, [s], p in assoc(s, :post))
    |> join(:left_lateral, [s, p], o in fragment("SELECT TRUE AS value FROM json_array_elements(?) AS body_block WHERE body_block->>'kind' = 'image'", p.body))
    |> where([s, p, has_body], not is_nil(has_body.value))
    |> group_by([s, p, has_body], s.id)
  end

  def daily_submissions(%{artist_invite: %{id: id}}) do
    ArtistInviteSubmission
    |> join(:left, [s], p in assoc(s, :post))
    |> where([s, p], s.artist_invite_id == ^id)
    |> group_by([s, p], fragment("date_trunc('day', ?)", p.created_at))
    |> select([s, p], %{
      submissions: count(s.id),
      date: fragment("date_trunc('day', ?)", p.created_at),
    })
    |> Repo.all
  end

  def total_submissions(%{artist_invite: %{id: id}}) do
    ArtistInviteSubmission
    |> where([s], s.artist_invite_id == ^id)
    |> group_by([s], s.status)
    |> select([s], %{
      submissions: count(s.id),
      status: s.status,
    })
    |> Repo.all
  end

  defp total_participants_query(id) do
    ArtistInviteSubmission
    |> join(:left, [s], p in assoc(s, :post))
    |> join(:left, [s, p], u in assoc(p, :author))
    |> join(:left, [s, p, u], c in assoc(u, :category_users))
    |> where([s, p, u, c], s.artist_invite_id == ^id)
  end

  def total_participants(%{artist_invite: %{id: id}}) do
    id
    |> total_participants_query
    |> group_by([s, p, u, c], fragment("""
      CASE
        WHEN ? = 'featured' THEN 'Influencer'
        WHEN ? = 'curator' THEN 'Influencer'
        ELSE 'Normal'
      END
    """, c.role, c.role))
    |> select([s, p, u, c], %{
      participants: count(u.id, :distinct),
      type: fragment("""
      CASE
        WHEN ? = 'featured' THEN 'Influencer'
        WHEN ? = 'curator' THEN 'Influencer'
        ELSE 'Normal'
      END
      """, c.role, c.role)
    })
    |> Repo.all
  end

  def artist_invite_comment_count(%{artist_invite: %{id: id}}) do
    Post
    |> join(:inner, [c], p in Post, c.parent_post_id == p.id or c.parent_post_id == p.reposted_source_id)
    |> join(:inner, [c, p], s in ArtistInviteSubmission, p.id == s.post_id or p.reposted_source_id == s.post_id)
    |> where([c, p, s], s.artist_invite_id == ^id)
    |> select([c], count(c.id, :distinct))
    |> Repo.one
  end

  def artist_invite_love_count(%{artist_invite: %{id: id}}) do
    Love
    |> join(:inner, [l], p in Post, l.post_id == p.id or l.post_id == p.reposted_source_id)
    |> join(:inner, [l, p], s in ArtistInviteSubmission, p.id == s.post_id or p.reposted_source_id == s.post_id)
    |> where([l, p, s], s.artist_invite_id == ^id)
    |> select([l], count(l.id, :distinct))
    |> Repo.one
  end

  def artist_invite_repost_count(%{artist_invite: %{id: id}}) do
    Post
    |> join(:inner, [rp], p in Post, rp.reposted_source_id == p.id)
    |> join(:inner, [rp, p], s in ArtistInviteSubmission, p.id == s.post_id)
    |> where([rp, p, s], s.artist_invite_id == ^id)
    |> select([rp], count(rp.id, :distinct))
    |> Repo.one
  end

  def artist_invite_mention_count(%{artist_invite: invite}) do
    invite = Repo.preload(invite, :brand_account)
    mention_stop = Timex.add(invite.closed_at, Timex.Duration.from_days(30))
    Post
    |> where([p], p.created_at > ^invite.created_at)
    |> where([p], p.created_at < ^mention_stop)
    |> where([p], fragment("? = ANY(?)", ^invite.brand_account.username, p.mentioned_usernames))
    |> select([p], count(p.id, :distinct))
    |> Repo.one
  end

  def artist_invite_follower_count(%{artist_invite: invite}) do
    mention_stop = Timex.add(invite.closed_at, Timex.Duration.from_days(30))
    Relationship
    |> where([r], r.created_at > ^invite.created_at)
    |> where([r], r.created_at < ^mention_stop)
    |> where([r], r.priority == "friend" and r.subject_id == ^invite.brand_account_id)
    |> select([p], count(p.id, :distinct))
    |> Repo.one
  end
end
