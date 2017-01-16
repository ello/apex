defmodule Ello.Auth.NetworkStub do
  @moduledoc """
  Taking the place of actual calls to Ello.Core.Network in Ello.Auth tests.

  Simply returns a generic values.
  """

  @doc "Return a map with the id given"
  def user(404), do: nil
  def user(id), do: %{id: id}
end
