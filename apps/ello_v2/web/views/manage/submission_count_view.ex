defmodule Ello.V2.Manage.SubmissionCountView do
  use Ello.V2.Web, :view

  def render("daily.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      daily_submissions: Enum.map(data, fn(day) ->
        {{y, m, d}, _} = day.date
        date = %Date{year: y, month: m, day: d}
        %{
          id: "daily_submissions:#{id}:all:#{date}",
          artist_invite_id: id,
          submissions: day.submissions,
          status: "all",
          date: date,
        }
      end)
    }
  end

  def render("total.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      total_submissions: Enum.map(data, fn(group) ->
        %{
          id: "total_submissions:#{id}:#{group.status}:total",
          artist_invite_id: id,
          submissions: group.submissions,
          status: String.capitalize(group.status),
        }
      end)
    }
  end

  def render("participants.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      total_participants: Enum.map(data, fn(group) ->
        %{
          id: "total_participants:#{id}:#{group.type}:total",
          artist_invite_id: id,
          participants: group.participants,
          type: group.type,
        }
      end)
    }
  end
end
