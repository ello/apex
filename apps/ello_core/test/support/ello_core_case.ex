defmodule Ello.Core.Case do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)
  end

  using do
    quote do
      alias Ello.Core
      alias Core.{
        Repo,
        Redis,
        Discovery,
        Network,
        Factory,
      }
      alias Network.{
        User,
        Relationship,
      }
      alias Discovery.{
        Category,
        Promotional,
      }
    end
  end
end
