defmodule Ello.V3.Resolvers.UserCategories do
  alias Ello.Core.{Discovery}

  def call(_parent, %{current_user: nil} = args, _resolver) do
    categories = args
                 |> Map.merge(%{primary: true})
                 |> Discovery.categories

    {:ok, categories}
  end
  def call(_parent, %{current_user: current_user} = args, _resolver) do
    categories = args
                 |> Map.merge(%{ids: current_user.followed_category_ids, promo: true})
                 |> Discovery.categories

    {:ok, categories}
  end
end
