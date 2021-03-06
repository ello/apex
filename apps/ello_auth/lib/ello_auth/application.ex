defmodule Ello.Auth.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ello.Auth.PublicToken, []),
    ]

    opts = [strategy: :one_for_one, name: Ello.Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
