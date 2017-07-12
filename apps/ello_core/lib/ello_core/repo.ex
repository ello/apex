defmodule Ello.Core.Repo do
  use Ecto.Repo, otp_app: :ello_core

  def after_connect(conn) do
    timeout = Application.get_env(:ello_core, :pg_statement_timeout)
    query = "SET SESSION statement_timeout = '#{timeout}'"
    {:ok, _} = Postgrex.query(conn, query, [])
  end

  def get_by_id_or_slug(query, id_or_slug: "~" <> slug),
    do: __MODULE__.get_by(query, slug: slug)
  def get_by_id_or_slug(query, id_or_slug: id) do
    id = String.to_integer(id)
    __MODULE__.get(query, id)
  end
end
