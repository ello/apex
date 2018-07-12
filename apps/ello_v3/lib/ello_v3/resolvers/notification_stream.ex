defmodule Ello.V3.Resolvers.NotificationStream do
  import Ello.V3.Resolvers.PostViewHelpers
  alias Ello.Notifications.Stream

  def call(_parent, args, _resolver) do
    stream = Stream.fetch(args)

    {:ok, %{
      notifications: track(stream.models, args, kind: :notifications),
      is_last_page: length(stream.models) < args.per_page,
      next: stream.next,
    }}
  end
end
