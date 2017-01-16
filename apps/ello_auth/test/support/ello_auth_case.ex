defmodule Ello.Auth.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test
      alias Ello.Auth.NetworkStub
    end
  end
end
