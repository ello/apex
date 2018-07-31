defmodule Ello.V3 do
  @moduledoc """
  Ello V3 Graphql API

    - Graphiql explorer available at /api/v3/graphiql
    - Graphql API avaiable at /api/v3/graphql
    - API requires same authentication bearer token as V2 API.
  """

  defmodule Authenticated do
    @moduledoc """
    Enforces bearer token
    """
    use Plug.Router
    plug Ello.Auth.RequireToken
    plug Ello.Auth.ClientProperties
    plug Ello.V3.Context
    plug :match
    plug :dispatch

    match "/api/v3/graphql", to: Absinthe.Plug, init_opts: [schema: Ello.V3.Schema, json_codec: Jason]
    match _ do
      send_resp(conn, 404, "Not found")
    end
  end

  use Plug.Router

  plug Ello.V3.Plug.NewRelic
  plug :match
  plug :dispatch

  if Application.get_env(:ello_v3, :allow_graphiql) do
    match "/api/v3/graphiql", to: Absinthe.Plug.GraphiQL, init_opts: [schema: Ello.V3.Schema, json_codec: Jason]
  end

  match "/api/v3/graphql",  to: Ello.V3.Authenticated
  match _ do
    send_resp(conn, 404, "Not found")
  end
end
