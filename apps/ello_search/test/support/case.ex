defmodule Ello.Search.Case do
  use ExUnit.CaseTemplate, async: false

  using do
    quote do
      alias Ello.Core.{Factory, FactoryTime, Factory.Script, Redis}
    end
  end

  setup _tags do
    Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)
  end
end
