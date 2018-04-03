defmodule Ello.Stream.Item do
  @type t :: %__MODULE__{id: String.t, stream_id: String.t, ts: Calendar.t, type: integer}

  @derive {Jason.Encoder, only: [:id, :stream_id, :ts, :type]}
  defstruct [id: "", stream_id: "", ts: nil, type: 0]

  @prefix    Application.get_env(:ello_stream, :prefix)
  @env       Application.get_env(:ello_stream, :env)
  @id_prefix [@env, @prefix]
             |> Enum.reject(&is_nil/1)
             |> Enum.join(":")

  def format_stream_id(@id_prefix <> _ = id), do: id
  def format_stream_id(id) when is_binary(id), do: @id_prefix <> ":" <> id
  def format_stream_id(%__MODULE__{stream_id: id} = item) do
    %{item | stream_id: format_stream_id(id)}
  end

  def from_json(%{
    "id" => id,
    "stream_id" => stream_id,
    "ts" => ts,
    "type" => type,
  }), do: %__MODULE__{
    id: id,
    stream_id: stream_id,
    ts: ts,
    type: type,
  }
end
