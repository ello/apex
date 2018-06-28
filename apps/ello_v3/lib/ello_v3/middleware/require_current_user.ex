defmodule Ello.V3.Middleware.RequireCurrentUser do
  alias Ello.Core.Network.User
  alias Absinthe.{
    Middleware,
    Resolution,
  }
  @behaviour Middleware

  @moduledoc """
  Middleware that requires a logged in user (as current user in args)
  """

  def call(%{context: %{current_user: %User{} = current_user}} = resolution, _), do: resolution
  def call(resolution, _), do: Resolution.put_result(resolution, {:error, "unauthenticated"})
end
