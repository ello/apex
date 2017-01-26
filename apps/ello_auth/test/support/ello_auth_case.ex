defmodule Ello.Auth.Case do
  use ExUnit.CaseTemplate

  # When running Ello.Auth tests use the network stub.
  setup_all do
    Application.put_env(:ello_auth, :user_lookup_mfa, {Ello.Auth.NetworkStub, :user})
    on_exit fn ->
      Application.put_env(:ello_auth, :user_lookup_mfa, {Ello.Core.Network, :load_current_user})
    end
  end

  using do
    quote do
      use Plug.Test
      alias Ello.Auth.NetworkStub
    end
  end
end
