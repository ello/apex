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

  def category_posts(nil, _), do: nil
  def category_posts([], _),  do: []
  def category_posts(category_posts, %{preloads: preloads}) do
    ecto_preloads = []
                    |> add_category_preload(preloads)
                    |> add_submitted_by_preload(preloads)
                    |> add_featured_by_preload(preloads)
    category_posts
    |> Repo.preload(ecto_preloads)
  end

  @editorial_default_preloads %{
    post: %{
      assets: %{},
      current_user_state: %{},
      categories: %{},
      artist_invite_submission: %{artist_invite: %{}},
      author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
      post_stats: %{},
      reposted_source: %{
        assets: %{},
        current_user_state: %{},
        categories: %{},
        artist_invite_submission: %{artist_invite: %{}},
        author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
        post_stats: %{},
      }
    }
  }

  def editorials(nil, _), do: nil
  def editorials([], _),  do: []
  def editorials(editorials, %{preloads: %{}} = options) do
    editorials
    |> preload_post(options)
    |> preload_curated_posts(options)
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

  defp preload_curated_posts(editorials, %{preloads: %{posts: post_preloads}} = options) do
    tokens = editorials
             |> Enum.flat_map(&(&1.content["post_tokens"] || []))
             |> Enum.uniq
    posts = options
            |> Map.merge(%{tokens: tokens, preloads: post_preloads})
            |> Content.posts
            |> Enum.reduce(%{}, &Map.put(&2, &1.token, &1))
    Enum.map editorials, fn
      %{content: %{"post_tokens" => []}} = e -> e
      %{content: %{"post_tokens" => nil}} = e -> e
      %{content: %{"post_tokens" => tokens}} = e ->
        curated_posts = posts
                        |> Map.take(e.content["post_tokens"])
                        |> Map.values
        Map.put(e, :curated_posts, curated_posts)
      e -> e
    end
  end
  defp preload_curated_posts(editorials, _), do: editorials

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

  defp add_submitted_by_preload(preloads, %{submitted_by: user_preloads}),
    do: [{:submitted_by, &Network.users(%{ids: &1, preloads: user_preloads})} | preloads]
  defp add_submitted_by_preload(preloads, _), do: preloads

  defp add_featured_by_preload(preloads, %{featured_by: user_preloads}),
    do: [{:featured_by, &Network.users(%{ids: &1, preloads: user_preloads})} | preloads]
  defp add_featured_by_preload(preloads, _), do: preloads
end
