defmodule Ello.V3.Middleware.NewRelic do
  @behaviour Absinthe.Middleware
  def init(opts), do: opts

  @doc """
  Update the current transaction with the graphql query name.
  """
  def call(resolution, _) do
    [_query | _] = Absinthe.Resolution.path(resolution)
    # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
    # newrelic until we have bandwidth to update our code, maybe to new_relic
    # NewRelicPhoenix.TransactionRegistry.current
    # |> Map.put(:name, "/graphql##{query}")
    # |> NewRelicPhoenix.TransactionRegistry.update
    resolution
  end
end
