defmodule Ello.Grandstand do
  alias Ello.Grandstand.Client

  def daily_impressions(%{artist_invite: invite}) do
    {start, stop} = artist_invite_range(invite)
    Client.fetch_impressions("/api/v1/artist_invites/#{invite.id}/daily", %{
      starting: start,
      ending:   stop,
    })
  end

  def total_impressions(%{artist_invite: invite}) do
    {start, stop} = artist_invite_range(invite)
    Client.fetch_impressions("/api/v1/artist_invites/#{invite.id}/total", %{
      starting: start,
      ending:   stop,
    })
  end

  defp artist_invite_range(invite) do
    starting_at = invite.opened_at
                  |> Timex.subtract(Timex.Duration.from_days(1))
                  |> Timex.format!("{YYYY}-{M}-{D}")
    ending_at = invite.closed_at
                |> Timex.add(Timex.Duration.from_days(30))
                |> Timex.format!("{YYYY}-{M}-{D}")
    {starting_at, ending_at}
  end
end
