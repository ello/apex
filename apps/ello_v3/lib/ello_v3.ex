defmodule Ello.V3 do
  @moduledoc """
  Top-Secret Experimental GraphQL Skunkworks Experiment
  """

  use Plug.Router

  # plug Ello.Auth.RequireToken
  plug :dev_user
  plug Ello.V3.Context
  plug :match
  plug :dispatch

  match "/api/v3/graphiql", to: Absinthe.Plug.GraphiQL, init_opts: [schema: Ello.V3.Schema]
  match "/api/v3/",         to: Absinthe.Plug,          init_opts: [schema: Ello.V3.Schema]

  def dev_user(conn, _) do
    if Mix.env == :dev do
      assign(conn, :current_user, Ello.Core.Network.load_current_user(139261))
    else
      conn
    end
  end
end
