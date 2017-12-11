defmodule Ello.Core.Repo do
  use Ecto.Repo, otp_app: :ello_core
  import Ecto.Query

  def after_connect(conn) do
    timeout = Application.get_env(:ello_core, :pg_statement_timeout)
    query = "SET SESSION statement_timeout = '#{timeout}'"
    {:ok, _} = Postgrex.query(conn, query, [])
  end

  def get_by_id_or_slug(query, id_or_slug: "~" <> slug),
    do: get_by(query, slug: slug)
  def get_by_id_or_slug(query, id_or_slug: id) when is_binary(id),
    do: get(query, String.to_integer(id))
  def get_by_id_or_slug(query, id_or_slug: id),
    do: get(query, id)

  def exists(query) do
    query
    |> select(1)
    |> limit(1)
    |> all
    |> case do
      [1] -> true
      []  -> false
    end
  end

  def to_sql(query) do
    Ecto.Adapters.SQL.to_sql(:all, __MODULE__, query)
  end
end
