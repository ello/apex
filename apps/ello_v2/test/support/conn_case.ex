defmodule Ello.V2.ConnCase do
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
  alias Ello.Auth.JWT

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import Ello.V2.Router.Helpers
      import Ello.V2.ConnCase, only: [auth_conn: 2, user_conn: 2, public_conn: 1]
      import Ello.V2.JsonSchema, only: [validate_json: 2]
      alias Ello.Core.{Factory, Factory.Script}

      # The default endpoint for testing
      @endpoint Ello.V2.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)
    conn = Phoenix.ConnTest.build_conn()
           |> Plug.Conn.put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  @doc """
  Takes a conn and a user and returns a conn with a auth token.
  Used for full request specs which hit authentication via routes.
  """
  def auth_conn(conn, user) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{JWT.generate(user)}")
  end

  @doc """
  Takes a conn retuns a conn with a public JWT token included.
  """
  def public_conn(conn) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{JWT.generate()}")
  end

  @doc """
  Takes a conn and a user and returns a conn with the user assigned.
  Used for view tests which do not execute authentication, but need conns.
  """
  def user_conn(conn, user) do
    Plug.Conn.assign(conn, :current_user, user)
  end
end
