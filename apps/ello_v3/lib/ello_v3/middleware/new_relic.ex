defmodule Ello.V3.Middleware.NewRelic do
  @behaviour Absinthe.Middleware
  def init(opts), do: opts

  @doc """
  Update the current transaction with the graphql query name.
  """
  def call(resolution, _) do
    [query | _] = Absinthe.Resolution.path(resolution)
    NewRelicPhoenix.TransactionRegistry.current
    |> Map.put(:name, "/graphql##{query}")
    |> NewRelicPhoenix.TransactionRegistry.update
    resolution
  end
end
