defmodule Ello.Serve.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ello.Serve.VersionStore

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import Ello.Serve.Router.Helpers
      alias Ello.Core.{Factory, FactoryTime, Repo, Redis}
      import Ello.Serve.ConnCase.Helpers

      # The default endpoint for testing
      @endpoint Ello.Serve.Endpoint
    end
  end

  setup _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)

    # Use in memory version store for controller tests, resets automatically
    Application.put_env(:ello_serve, :version_store_adapter, VersionStore.Memory)
    VersionStore.Memory.start()
    html = File.read!("test/support/ello.co.html")
    VersionStore.put_version("webapp", "ello", html)
    VersionStore.activate_version("webapp", "ello")
    on_exit fn() ->
      VersionStore.Memory.reset()
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  defmodule Helpers do

    def has_meta(html, args) when is_list(args),
      do: has_meta(html, Enum.into(args, %{}))
    def has_meta("", _),
      do: false
    def has_meta(html, args) do
      Enum.all?(args, &meta_attribute_present?(html, &1))
    end

    defp meta_attribute_present?(html, {key, value}) do
      Regex.match?(~r(<meta .*#{key}="#{value}".*/>), html)
    end
  end
end
