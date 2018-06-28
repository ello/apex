defmodule Ello.Core.Discovery.Preload do
  import Ecto.Query
  alias Ello.Core.{Repo, Network, Discovery, Content, Network}
  alias Discovery.{Category, Promotional, Editorial}
  alias Network.CategoryUser

  @doc "TODO"
  def categories(nil, _), do: nil
  def categories([], _),  do: []
  def categories(categories, options) do
    categories
    |> include_promotionals(options)
    |> include_category_users(options)
    |> include_current_user_state(options)
    |> build_category_images(options)
  end

  def category_posts(nil, _), do: nil
  def category_posts([], _),  do: []
  def category_posts(category_posts, %{preloads: preloads}) do
    ecto_preloads = []
                    |> add_category_preload(preloads)
                    |> add_submitted_by_preload(preloads)
                    |> add_featured_by_preload(preloads)
    Repo.preload(category_posts, ecto_preloads)
  end

  def category_users(nil, _), do: nil
  def category_users([], _),  do: []
  def category_users(category_users, %{preloads: preloads} = options) do
    ecto_preloads = []
                    |> add_category_preload(preloads)
                    |> add_user_preload(preloads, options[:current_user])
    Repo.preload(category_users, ecto_preloads)
  end

  @editorial_default_preloads %{post: Content.Preload.post_default_preloads}

  def editorials(nil, _), do: nil
  def editorials([], _),  do: []
  def editorials(editorials, %{preloads: %{}} = options) do
    editorials
    |> preload_post(options)
    |> build_editorial_images
  end
  def editorials(editorials, options),
    do: editorials(editorials, Map.put(options, :preloads, @editorial_default_preloads))

  # For "post" type support both posts and post as preload name
  defp preload_post(editorials, %{preloads: %{post: post_preloads}} = options) do
    preload_post(editorials, %{options | preloads: %{posts: post_preloads}})
  end
  defp preload_post(editorials, %{preloads: %{posts: post_preloads}} = options) do
    Repo.preload(editorials, [
      {:post, &(Content.posts(Map.merge(options, %{ids: &1, preloads: post_preloads})))}
    ])
  end
  defp preload_post(editorials, _), do: editorials

  def promotionals([], _), do: []
  def promotionals(promotions, options) do
    promotions
    |> promotional_includes(options)
    |> build_promotional_images
  end

  def page_promotionals([], _), do: []
  def page_promotionals(promotions, options) do
    promotions
    |> page_promotional_includes(options)
    |> build_promotional_images
  end

  defp include_promotionals(categories, %{promotionals: true} = options) do
    Repo.preload(categories, promotionals: [user: &Network.users(%{ids: &1, current_user: options[:current_user]})])
  end
  defp include_promotionals(categories, _), do: categories

  defp include_category_users(categories, %{preloads: %{category_users: cuser_preloads}} = opts) do
    {args, preloads} = Map.pop(cuser_preloads, :args, %{})
    opts = opts
           |> Map.merge(args)
           |> Map.put(:preloads, preloads)
           |> Map.put(:category_ids, nil)

    Repo.preload(categories, [
      category_users: &Discovery.category_users(%{opts | category_ids: &1})
    ])
  end
  defp include_category_users(categories, _), do: categories


  defp include_current_user_state(categories, %{current_user: %{id: id}, preloads: %{current_user_state: _}}) do
    Repo.preload(categories, [{:current_user_state, where(CategoryUser, user_id: ^id)}])
  end
  defp include_current_user_state(categories, _), do: categories


  defp promotional_includes(promotionals, %{preloads: preloads} = options) do
    preloads = Enum.map preloads, fn
      ({:category, _}) -> :category
      ({:user, user_preloads}) ->
        {:user, &Network.users(%{ids: &1, current_user: options[:current_user], preloads: user_preloads})}
    end
    Repo.preload(promotionals, preloads)
  end

  defp page_promotional_includes(promotionals, %{preloads: preloads} = options) do
    preloads = Enum.map preloads, fn
      ({:user, user_preloads}) ->
        {:user, &Network.users(%{ids: &1, current_user: options[:current_user], preloads: user_preloads})}
      _ -> nil
    end
    preloads = Enum.filter(preloads, &(&1))
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

  defp add_category_preload(preloads, %{category: category_preloads}),
    do: [{:category, &Discovery.categories(%{ids: &1, preloads: category_preloads})} | preloads]
  defp add_category_preload(preloads, _), do: preloads

  defp add_user_preload(preloads, %{user: user_preloads}, current_user) do
    [{:user, &Network.users(%{ids: &1, preloads: user_preloads, current_user: current_user})} | preloads]
  end
  defp add_user_preload(preloads, _, _current_user), do: preloads

  defp add_submitted_by_preload(preloads, %{submitted_by: user_preloads}),
    do: [{:submitted_by, &Network.users(%{ids: &1, preloads: user_preloads})} | preloads]
  defp add_submitted_by_preload(preloads, _), do: preloads

  defp add_featured_by_preload(preloads, %{featured_by: user_preloads}),
    do: [{:featured_by, &Network.users(%{ids: &1, preloads: user_preloads})} | preloads]
  defp add_featured_by_preload(preloads, _), do: preloads
end
