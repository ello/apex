defmodule Ello.Core.ContestTest do
  use Ello.Core.Case
  alias Ello.Core.Contest
  alias Ello.Core.Repo

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    invite = Factory.insert(:artist_invite, %{status: "open"})
    approved = Factory.insert_list(4, :artist_invite_submission, %{
      artist_invite: invite,
      status:        "approved",
    })
    approved_with_images = Factory.insert_list(4, :artist_invite_submission, %{
      artist_invite: invite,
      status:        "approved",
      post:          Factory.add_assets(Factory.insert(:post))
    })

    {:ok, [
      invite: invite,
      approved: approved,
      approved_with_images: approved_with_images,
    ]}
  end

  test "fetching approves artist invite submissions", context do
    results = Contest.artist_invite_submissions(%{
      allow_nsfw:   true,
      allow_nudity: true,
      current_user: nil,
      per_page:     100,
      before:       nil,
      invite:       context[:invite],
      images_only:  false,
      status:       "approved",
    })

    ids = Enum.map(results, &(&1.id))
    Enum.each context[:approved], fn(sub) ->
      assert sub.id in ids
    end
    Enum.each context[:approved_with_images], fn(sub) ->
      assert sub.id in ids
    end
  end

  test "fetching approves artist invite submissions - images only", context do
    results = Contest.artist_invite_submissions(%{
      allow_nsfw:   true,
      allow_nudity: true,
      current_user: nil,
      per_page:     100,
      before:       nil,
      invite:       context[:invite],
      images_only:  true,
      status:       "approved",
    })

    ids = Enum.map(results, &(&1.id))
    Enum.each context[:approved], fn(sub) ->
      refute sub.id in ids
    end
    Enum.each context[:approved_with_images], fn(sub) ->
      assert sub.id in ids
    end
    assert length(ids) == length(context[:approved_with_images])
  end
end
