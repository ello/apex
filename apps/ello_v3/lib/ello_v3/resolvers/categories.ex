defmodule Ello.V3.Resolvers.Categories do
  alias Ello.Core.{Discovery}

  def call(_parent, args, _resolver), do: {:ok, Discovery.categories(Map.merge(args, %{promo: true}))}
end
