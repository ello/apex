defmodule Ello.Events.TrackPostViews do
  alias Ello.Events
  alias Events.CountPostView
  alias Plug.Conn
  alias Ello.Core.Content.{
    Post,
    Love,
  }
  alias Ello.Core.Discovery.{
    Editorial,
  }
  import Phoenix.Controller, only: [action_name: 1]

  @moduledoc """
  Shared logic for tracking post views.
  """

  def track(conn, models, options \\ [])
  def track(models, %Conn{} = conn, options),
    do: track(conn, models, options)
  def track(conn, [], _options),
    do: conn
  def track(conn, nil, _options),
    do: conn
  def track(conn, models, options) do
    Events.publish(%CountPostView{
      post_ids:    post_ids(models),
      user_id:     user_id(conn),
      stream_kind: stream_kind(conn, options),
      stream_id:   stream_id(options),
    })
    conn
  end

  defp user_id(%{assigns: %{current_user: %{id: id}}}), do: id
  defp user_id(_), do: nil

  defp stream_kind(conn, opts) do
    case {opts[:stream_kind], conn.params["stream_source"]} do
      {nil, nil}     -> action_name(conn)
      {nil, source}  -> "#{action_name(conn)}_#{source}"
      {kind, nil}    -> kind
      {kind, source} -> "#{kind}_#{source}"
    end
  end

  defp stream_id(opts), do: "#{opts[:stream_id]}"

  defp post_ids(%Post{id: id}),
    do: [id]
  defp post_ids([%Post{} | _] = posts),
    do: Enum.map(posts, &(&1.id))

  defp post_ids([%Editorial{} | _] = editorials) do
    editorials
    |> Enum.map(&(&1.post))
    |> Enum.reject(&is_nil/1)
    |> post_ids
  end

  defp post_ids([%Love{} | _] = loves) do
    loves
    |> Enum.map(&(&1.post))
    |> Enum.reject(&is_nil/1)
    |> post_ids
  end
end
