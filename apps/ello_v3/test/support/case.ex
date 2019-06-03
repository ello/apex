defmodule Ello.V3.Case do
  use ExUnit.CaseTemplate
  use Plug.Test
  alias Ello.Auth.JWT

  using do
    quote do
      alias Ello.Core.{
        Factory,
        FactoryTime,
        Factory.Script,
        Repo,
      }
      import Ello.V3.Case
    end
  end

  setup _tags do
    Ecto.Adapters.SQL.Sandbox.checkout(Ello.Core.Repo)
  end

  def post_graphql(body, user \\ nil) do
    jwt = if user, do: JWT.generate(user), else: JWT.generate()
    :post
    |> conn("/api/v3/graphql", body)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("accepts", "application/json")
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> Ello.V3.call([])
  end

  def json_response(conn) do
    Jason.decode!(conn.resp_body)
  end
end
