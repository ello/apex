defmodule Ello.V2.Manage.ImpressionCountView do
  use Ello.V2.Web, :view

  def render("daily.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      daily_impressions: Enum.map(data, fn(day) ->
        %{
          id: "daily_impressions:#{id}:#{day.stream_kind || "all"}:#{day.date}",
          artist_invite_id: id,
          impressions: day.impressions,
          stream_kind: day.stream_kind,
          date: day.date,
        }
      end)
    }
  end

  def render("total.json", %{data: data, artist_invite: artist_invite}) do
    id = "#{artist_invite.id}"
    %{
      total_impressions: Enum.map(data, fn(group) ->
        %{
          id: "total_impressions:#{id}:#{group.stream_kind || "all"}",
          artist_invite_id: id,
          impressions: group.impressions,
          stream_kind: group.stream_kind,
        }
      end)
    }
  end
end
