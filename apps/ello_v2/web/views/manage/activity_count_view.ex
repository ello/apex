defmodule Ello.V2.Manage.ActivityCountView do
  use Ello.V2.Web, :view

  def render("all.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      total_activities: [
        %{
          id: "total_activities:#{id}:comments",
          artist_invite_id: id,
          activities: data.comments,
          type: "comments",
        },
        %{
          id: "total_activities:#{id}:loves",
          artist_invite_id: id,
          activities: data.loves,
          type: "loves",
        },
        %{
          id: "total_activities:#{id}:reposts",
          artist_invite_id: id,
          activities: data.reposts,
          type: "reposts",
        },
        %{
          id: "total_activities:#{id}:followers",
          artist_invite_id: id,
          activities: data.followers,
          type: "followers",
        },
        %{
          id: "total_activities:#{id}:mentions",
          artist_invite_id: id,
          activities: data.mentions,
          type: "mentions",
        }
      ]
    }
  end
end
