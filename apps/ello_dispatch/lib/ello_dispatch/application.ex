defmodule Ello.Dispatch.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Ello.Dispatch.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Ello.Dispatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
