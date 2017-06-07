defmodule Ello.Core.Repo do
  use Ecto.Repo, otp_app: :ello_core

  def after_connect(conn) do
    timeout = Application.get_env(:ello_core, :pg_statement_timeout)
    query = "SET SESSION statement_timeout = '#{timeout}'"
    {:ok, _} = Postgrex.query(conn, query, [])
  end
end
