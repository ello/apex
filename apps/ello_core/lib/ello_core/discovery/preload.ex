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

  defp include_promotionals(categories, %{promotionals: true} = options) do
    Repo.preload(categories, promotionals: [user: &Network.users(&1, options[:current_user])])
  end
  defp include_promotionals(categories, _), do: categories

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
end
