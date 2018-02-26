defmodule Ello.Core.Discovery do
  import Ecto.Query
  alias Ello.Core.{Repo, Network}
  alias __MODULE__.{Category, Editorial, Preload, Promotional, PagePromotional}
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

  Options:

    * id_or_slug -   integer id or binary slug to fetch.
    * images -       build image - default true.
    * promotionals - include promotionals - default false.
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

  @doc """
  Return C (filtered by other options)ategories.

  Fetch options:

    * ids -          fetch by ids - if not present all categories returned (filtered by other options).
    * inactive -     include inactive category
    * meta -         include meta categories
    * primary -      only return primary categories
  """
  @spec categories(options) :: [Category.t]
  def categories(%{ids: ids} = options) do
    Category
    |> where([c], c.id in ^ids)
    |> include_inactive_categories(options[:inactive])
    |> include_meta_categories(options[:meta])
    |> priority_order
    |> Repo.all
    |> Preload.categories(options)
  end
  def categories(%{creator_types: true} = options) do
    Category
    |> where(is_creator_type: true)
    |> Repo.all
    |> Preload.categories(options)
  end
  def categories(%{primary: true} = options) do
    Category
    |> where(level: "primary")
    |> Repo.all
    |> Preload.categories(options)
  end
  def categories(options) do
    Category
    |> include_inactive_categories(options[:inactive])
    |> include_meta_categories(options[:meta])
    |> priority_order
    |> Repo.all
    |> Preload.categories(options)
  end

  @doc """
  Return Editorials

  Fetch options:

    * preview -  return staff preview or publicly published list of editorials?
    * before -   pagination cursor
    * per_page - how many per page.
  """
  @spec editorials(options) :: [Editorial.t]
  def editorials(%{preview: false} = options) do
    Editorial
    |> where([e], not is_nil(e.published_position))
    |> filter_kinds(options[:kinds])
    |> order_by(desc: :published_position)
    |> editorial_cursor(options)
    |> limit(^options[:per_page])
    |> Repo.all
    |> Preload.editorials(options)
    |> filter_missing_posts
  end
  def editorials(%{preview: true} = options) do
    Editorial
    |> where([e], not is_nil(e.preview_position))
    |> order_by(desc: :preview_position)
    |> editorial_cursor(options)
    |> limit(^options[:per_page])
    |> Repo.all
    |> Preload.editorials(options)
    |> filter_missing_posts
  end

  defp filter_kinds(query, nil), do: query
  defp filter_kinds(query, []), do: query
  defp filter_kinds(query, kinds) do
    where(query, [e], e.kind in ^kinds)
  end

  defp filter_missing_posts(editorials) do
    Enum.reject editorials, fn
      %{kind: "post", post: nil} -> true
      _ -> false
    end
  end

  defp editorial_cursor(query, %{before: nil}), do: query
  defp editorial_cursor(query, %{preview: true, before: before}) do
    case editorial_before(before) do
      nil    -> query
      before -> where(query, [e], e.preview_position < ^before)
    end
  end
  defp editorial_cursor(query, %{preview: false, before: before}) do
    case editorial_before(before) do
      nil    -> query
      before -> where(query, [e], e.published_position < ^before)
    end
  end

  defp editorial_before(before), do: String.replace(before, ~r"\D", "")

  @doc """
  Return Category Promotionals

  Fetch options:

    * slug - the category from which to get the promotion
    * per_page - how many to get - pagination not supported, just a limit
  """
  @spec promotionals(options) :: [Promotional.t]
  def promotionals(%{slug: slug, per_page: per_page} = options) do
    Promotional
    |> join(:left, [promotional], category in assoc(promotional, :category))
    |> where([promotional, category], category.slug == ^slug)
    |> limit(^per_page)
    |> Repo.all
    |> Preload.promotionals(options)
  end

  @doc """
  Return Page Promotionals

  Fetch options:

    * slug - the category from which to get the promotion
    * per_page - how many to get - pagination not supported, just a limit
  """
  @spec page_promotionals(options) :: [PagePromotional.t]
  def page_promotionals(%{per_page: per_page} = options) do
    PagePromotional
    |> page_promotional_by_kind(options[:kind])
    |> page_promotional_by_login_status(options[:kind], options[:current_user])
    |> limit(^per_page)
    |> Repo.all
    |> Preload.page_promotionals(options)
  end

  defp page_promotional_by_kind(q, :editorial), do: where(q, is_editorial: true)
  defp page_promotional_by_kind(q, :artist_invite), do: where(q, is_artist_invite: true)
  defp page_promotional_by_kind(q, :authentication), do: where(q, is_authentication: true)
  defp page_promotional_by_kind(q, _),
    do: where(q, is_artist_invite: false, is_editorial: false, is_authentication: false)

  defp page_promotional_by_login_status(q, :generic, nil), do: where(q, is_logged_in: false)
  defp page_promotional_by_login_status(q, :generic, _), do: where(q, is_logged_in: true)
  defp page_promotional_by_login_status(q, _, _), do: q

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
    category_ids = categorizables
                   |> Enum.flat_map(&(&1.category_ids || []))
                   |> Enum.uniq
    categories = %{ids: category_ids}
                 |> categories
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
