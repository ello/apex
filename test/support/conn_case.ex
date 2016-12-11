defmodule Ello.ConnCase do
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

      alias Ello.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Ello.Router.Helpers

      import Ello.ConnCase, only: [auth_conn: 2]

      # The default endpoint for testing
      @endpoint Ello.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ello.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()
           |> Plug.Conn.put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  def auth_conn(conn, user) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{gen_token(user)}")
  end

  defp gen_token(%Ello.User{} = user) do
    payload = %{
      exp: Joken.current_time + 10,
      iss: "Ello, PBC",
      data: %{
        id: user.id,
        username: user.username,
      }
    }
    payload
    |> Joken.token
    |> Joken.with_signer(Ello.JWT.hs256_signer)
    |> Joken.sign
    |> Joken.get_compact
  end
end
