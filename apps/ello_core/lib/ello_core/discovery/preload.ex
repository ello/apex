defmodule Ello.Core.Discovery.Preload do
  alias Ello.Core.{Repo, Network, Discovery, Content}
  alias Discovery.{Category, Promotional, Editorial}

  @doc "TODO"
  def categories(nil, _), do: nil
  def categories([], _),  do: []
  def categories(categories, options) do
    categories
    |> include_promotionals(options)
    |> build_category_images(options)
  end

  @doc "TODO"
  def editorials(nil, _), do: nil
  def editorials([], _),  do: []
  def editorials(editorials, options) do
    editorials
    |> Repo.preload(post: &(Content.posts(Map.put(options, :ids, &1))))
    |> build_editorial_images
  end

  def promotionals([], _), do: []
  def promotionals(promotions, options) do
    promotions
    |> promotional_includes(options)
    |> build_promotional_images
  end

  defp include_promotionals(categories, %{promotionals: true} = options) do
    Repo.preload(categories, promotionals: [user: &Network.users(%{ids: &1, current_user: options[:current_user]})])
  end
  defp include_promotionals(categories, _), do: categories

  defp promotional_includes(promotionals, %{preloads: preloads} = options) do
    preloads = Enum.map preloads, fn
      ({:category, _}) -> :category
      ({:user, user_preloads}) ->
        {:user, &Network.users(%{ids: &1, current_user: options[:current_user], preloads: user_preloads})}
    end
    Repo.preload(promotionals, preloads)
  end

  defp build_category_images(categories, %{images: false}), do: categories
  defp build_category_images(categories, _), do: build_category_images(categories)
  defp build_category_images(categories) when is_list(categories) do
    Enum.map(categories, &build_category_images/1)
  end
  defp build_category_images(%Category{promotionals: promos} = category) when is_list(promos) do
    category
    |> Category.load_images
    |> Map.put(:promotionals, Enum.map(promos, &Promotional.load_images/1))
  end
  defp build_category_images(%Category{} = category) do
    Category.load_images(category)
  end

  defp build_editorial_images([]), do: []
  defp build_editorial_images(editorials),
    do: Enum.map(editorials, &Editorial.build_images/1)

  defp build_promotional_images(promotionals),
    do: Enum.map(promotionals, &Promotional.load_images/1)
end
