defmodule Ello.V3.Resolvers.SearchCategories do
  alias Ello.Core.{Discovery}

  def call(_parent, args, _resolver) do
    {:ok, %{
      categories: Discovery.categories(args),
    }}
  end
end
