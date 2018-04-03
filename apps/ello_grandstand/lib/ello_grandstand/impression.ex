defmodule Ello.Grandstand.Impression do
  defstruct [:impressions, :date, :stream_kind, :artist_invite_id]

  def from_json(%{
    "impressions" => impressions,
    "stream_kind" => stream_kind,
    "artist_invite_id" => artist_invite_id,
  } = json), do: %__MODULE__{
    impressions: impressions,
    date: json["date"],
    stream_kind: stream_kind,
    artist_invite_id: artist_invite_id,
  }

end
