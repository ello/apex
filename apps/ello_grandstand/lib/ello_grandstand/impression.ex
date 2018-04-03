defmodule Ello.Grandstand.Impression do
  defstruct [:impressions, :date, :stream_kind, :artist_invite_id]

  def from_json(%{
    "impressions" => impressions,
    "date" => date,
    "stream_kind" => stream_kind,
    "artist_invite_id" => artist_invite_id,
  }), do: %__MODULE__{
    impressions: impressions,
    date: date,
    stream_kind: stream_kind,
    artist_invite_id: artist_invite_id,
  }

end
