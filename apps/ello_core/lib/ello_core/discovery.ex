defmodule Ello.Core.Discovery do
  import Ecto.Query
  alias Ello.Core.{Repo, Network}
  alias __MODULE__.{Category, Editorial, Preload}
  alias Network.User

  @moduledoc """
  Responsible for retreiving and loading categories and related data.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @typedoc """
  All Ello.Core.Discovery public functions expect to receive a map of options.
  Those options should always include `current_user`, `allow_nsfw`, and
  `allow_nudity`. Any extra options should be included in the same map.
  """
  @type options :: %{
    required(:current_user) => User.t | nil,
    required(:allow_nsfw)   => boolean,
    required(:allow_nudity) => boolean,
    optional(:id_or_slug)   => integer | String.t,
    optional(:promotionals) => boolean,
    optional(:skip_images)  => boolean,
    optional(any)           => any
  }

  @doc """
  Find a single category by slug or id

  Loads promotionals if `promotionals` option is set to true.
  Skips images only if `skip_image` option is true.
  """
  @spec category(options) :: Category.t
  def category(%{id_or_slug: slug} = options) when is_binary(slug) do
    Category
    |> Repo.get_by(slug: slug)
    |> Preload.categories(options)
  end
  def category(%{id_or_slug: id} = options) when is_number(id) do
    Category
    |> Repo.get(id)
    |> Preload.categories(options)
  end

  @doc "Find a single category by slug - without includes"
  @spec category_without_includes(String.t) :: Category.t
  def category_without_includes(slug) do
    Category
    |> Repo.get_by(slug: slug)
  end

  @doc "Find multiple categories by ids - without includes"
  @spec categories_without_includes(ids :: [integer]) :: [Category.t]
  def categories_without_includes(ids) do
    Category
    |> where([u], u.id in ^ids)
    |> Repo.all
  end

  @doc "Find all primary categories - without includes"
  @spec primary_categories() :: [Category.t]
  def primary_categories do
    Category
    |> where(level: "primary")
    |> Repo.all
  end

  def categories_by_ids([]), do: []
  def categories_by_ids(ids) when is_list(ids) do
    Category
    |> where([c], c.id in ^ids)
    |> include_inactive_categories(false)
    |> include_meta_categories(false)
    |> Repo.all
    |> Preload.categories(%{}) # TODO
  end

  def editorials(%{preview: false} = options) do
    Editorial
    |> where([e], not is_nil(e.published_position))
    |> order_by(desc: :published_position)
    |> editorial_cursor(options)
    |> limit(^options[:per_page])
    |> Repo.all
    |> Preload.editorials(options)
  end
  def editorials(%{preview: true} = options) do
    Editorial
    |> where([e], not is_nil(e.preview_position))
    |> order_by(desc: :preview_position)
    |> editorial_cursor(options)
    |> limit(^options[:per_page])
    |> Repo.all
    |> Preload.editorials(options)
  end

  defp editorial_cursor(query, %{before: nil}), do: query
  defp editorial_cursor(query, %{preview: true, before: before}),
    do: where(query, [e], e.preview_position < ^before)
  defp editorial_cursor(query, %{preview: false, before: before}),
    do: where(query, [e], e.published_position < ^before)

  @type categorizable :: User.t | Post.t | [User.t | Post.t]

  @doc """
  Fetches the categories for a user or post

  Given a user or post struct (or list of users or posts), this function will
  fetch all the categories and include them in the struct (or list of structs).
  """
  @spec put_belongs_to_many_categories(categorizables :: categorizable | nil) :: categorizable | nil
  def put_belongs_to_many_categories(nil), do: nil
  def put_belongs_to_many_categories([]), do: []
  def put_belongs_to_many_categories(%{} = categorizable),
    do: hd(put_belongs_to_many_categories([categorizable]))
  def put_belongs_to_many_categories(categorizables) do
    categories = categorizables
                 |> Enum.flat_map(&(&1.category_ids || []))
                 |> categories_by_ids
                 |> Enum.group_by(&(&1.id))
    Enum.map categorizables, fn
      %{category_ids: nil} = categorizable -> categorizable
      %{category_ids: []} = categorizable -> categorizable
      categorizable ->
        categorizable_categories = categories
                                   |> Map.take(categorizable.category_ids)
                                   |> Map.values
                                   |> List.flatten
        Map.put(categorizable, :categories, categorizable_categories)
    end
  end

  @doc """

  TODO FIXUP
  Return all Categories. with related promotionals their user.

  By default neither "meta" categories nor "inactive" categories are included
  in the results. Pass `meta: true` or `inactive: true` as opts to include them.
  """
  @spec categories(options) :: [Category.t]
  def categories(options) do
    Category
    |> include_inactive_categories(options[:inactive])
    |> include_meta_categories(options[:meta])
    |> priority_order
    |> Repo.all
    |> Preload.categories(options)
  end

  # Category Scopes
  defp priority_order(q),
    do: order_by(q, [:level, :order])

  defp include_inactive_categories(q, true), do: q
  defp include_inactive_categories(q, _),
    do: where(q, [c], not is_nil(c.level))

  defp include_meta_categories(q, true), do: q
  defp include_meta_categories(q, _),
    do: where(q, [c], c.level != "meta" or is_nil(c.level))

end
