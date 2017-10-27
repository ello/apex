defmodule Ello.V2.Manage.SubmissionCountView do
  use Ello.V2.Web, :view

  def render("daily.json", %{data: data, artist_invite: artist_invite}) do
    %{
      daily_submissions: Enum.map(data, fn(day) ->
        {{y,m,d}, _} = day.date
        date = %Date{year: y, month: m, day: d}
        %{
          id: "daily_submissions:#{artist_invite.id}:#{date}",
          submissions: day.submissions,
          type: "all",
          date: date,
        }
      end)
    }
  end
end
