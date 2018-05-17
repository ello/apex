defmodule Ello.V3.Resolvers.Category do
  alias Ello.Core.{Discovery}

  def call(_parent, args, _resolver),
    do: {:ok, Discovery.category(Map.merge(args, %{id_or_slug: args[:slug]}))}
end
