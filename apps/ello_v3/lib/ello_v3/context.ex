defmodule Ello.V3.Context do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _),
    do: put_private(conn, :absinthe, %{context: build_context(conn)})

  def build_context(%Plug.Conn{assigns: assigns}),
    do: %{
      current_user: assigns[:current_user],
      allow_nudity: assigns[:allow_nudity],
      allow_nsfw: assigns[:allow_nsfw],
    }
end
