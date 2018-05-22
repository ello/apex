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
  alias Ello.Core.Contest.{
    ArtistInviteSubmission,
  }
  import Phoenix.Controller, only: [action_name: 1]

  @moduledoc """
  Shared logic for tracking post views.
  """

  def track(conn, models, options \\ [])
  def track(models, %Conn{} = conn, options) do
    track(conn, models, options)
    models
  end
  def track(conn, [], _options),
    do: conn
  def track(conn, nil, _options),
    do: conn
  def track(conn, models, options) do
    case post_ids(models) do
      []       -> conn
      ids -> Events.publish(%CountPostView{
        post_ids:    ids,
        user_id:     user_id(conn, options),
        stream_kind: stream_kind(conn, options),
        stream_id:   stream_id(options),
      })
      conn
    end
  end

  defp user_id(%{assigns: %{current_user: %{id: id}}}, _), do: id
  defp user_id(_, %{user: %{id: id}}), do: id
  defp user_id(_, _), do: nil

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
  defp post_ids([]), do: []

  @post_wrappers [Editorial, Love, ArtistInviteSubmission]
  defp post_ids([%{__struct__: kind} | _] = model) when kind in @post_wrappers do
    model
    |> Enum.map(&(&1.post))
    |> Enum.reject(&is_nil/1)
    |> post_ids
  end
end
