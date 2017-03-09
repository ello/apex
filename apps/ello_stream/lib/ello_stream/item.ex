defmodule Ello.Stream.Item do
  @type t :: %__MODULE__{id: String.t, stream_id: String.t, ts: Calendar.t, type: integer}
  defstruct [id: "", stream_id: "", ts: nil, type: 0]

  @prefix    Application.get_env(:ello_stream, :prefix)
  @env       Application.get_env(:ello_stream, :env)
  @id_prefix [@prefix, @env]
             |> Enum.reject(&is_nil/1)
             |> Enum.join(":")

  def format_stream_id(@id_prefix <> _ = id), do: id
  def format_stream_id(id) when is_binary(id), do: @id_prefix <> ":" <> id
  def format_stream_id(%__MODULE__{stream_id: id} = item) do
    %{item | stream_id: format_stream_id(id)}
  end
end
