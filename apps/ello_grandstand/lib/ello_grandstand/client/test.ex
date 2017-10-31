defmodule Ello.Grandstand.Client.Test do
  alias Ello.Grandstand.Impression
  @behaviour Ello.Grandstand.Client

  def start, do: Agent.start(fn -> [] end, name: __MODULE__)

  def reset, do: Agent.update(__MODULE__, fn(_) -> [] end)

  def add(impression) do
    Agent.update(__MODULE__, fn(state) ->
      [struct(Impression, impression) | state]
    end)
  end

  def fetch_impressions("/api/v1/artist_invites/" <> id_type, params) do
    [id, type] = String.split(id_type, "/")
    case type do
      "daily" -> daily_artist_invite_impressions(id, params)
      "total" -> total_artist_invite_impressions(id, params)
    end
  end

  defp daily_artist_invite_impressions(id, params) do
    Agent.get(__MODULE__, fn(impressions) ->
      impressions
      |> Enum.filter(&(&1.artist_invite_id == id))
      |> filter_range(params)
    end)
  end

  defp total_artist_invite_impressions(id, params) do
    Agent.get(__MODULE__, fn(impressions) ->
      impressions
      |> Enum.filter(&(&1.artist_invite_id == id))
      |> filter_range(params)
      |> Enum.reduce(%Impression{artist_invite_id: id, impressions: 0}, fn(imp, accum) ->
        Map.put(accum, :impressions, imp.impressions + accum.impressions)
      end)
      |> List.wrap
    end)
  end

  defp filter_range(impressions, %{starting: starting, ending: ending}) do
    # add day, because comparison operators are non-inclusive
    starting = Timex.subtract(to_date(starting), Timex.Duration.from_days(1))
    ending = Timex.add(to_date(ending), Timex.Duration.from_days(1))

    impressions
    |> Enum.filter(&Timex.after?(to_date(&1.date), starting))
    |> Enum.filter(&Timex.before?(to_date(&1.date), ending))
  end

  defp to_date(str), do: Timex.parse!(str, "{YYYY}-{M}-{D}")
end
