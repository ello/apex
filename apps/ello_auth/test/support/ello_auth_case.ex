defmodule Ello.Auth.Case do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)
  end

  using do
    quote do
      use Plug.Test
      alias Ello.Core.Factory
    end
  end
end
