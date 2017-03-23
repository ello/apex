defmodule Ello.Stream.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      :hackney_pool.child_spec(:roshi, [timeout: 15_000, max_connections: roshi_pool()])
    ]

    opts = [strategy: :one_for_one, name: Ello.Stream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp roshi_pool do
    Application.get_env(:ello_stream, :roshi_pool_size)
  end
end
