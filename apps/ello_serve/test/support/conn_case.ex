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

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import Ello.Serve.Router.Helpers
      alias Ello.Core.Factory
      import Ello.Serve.ConnCase.Helpers

      # The default endpoint for testing
      @endpoint Ello.Serve.Endpoint
    end
  end

  setup _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)

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
