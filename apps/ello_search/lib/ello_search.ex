defmodule Ello.Search do
  alias Ello.Search.{Client}
  import NewRelicPhoenix, only: [measure_segment: 2]

  @moduledoc """
  Shared helpers for searching.
  """

  @doc """
  Paginate an elastic search query based on the page and per page params.
  """
  def paginate(search = %{page: page, per_page: per_page}) do
    page = page - 1 # elasticsearch first page is 0, we use 1 as first
    search
    |> update_in([Access.key!(:query), :from], &(&1 = page * per_page))
    |> update_in([Access.key!(:query), :size], &(&1 = per_page))
  end

  @doc """
  Execute a query against an index.
  """
  def execute(%{query: query, index: index} = search) do
    measure_segment {:ext, "search_#{index.index_name()}"} do
      {:ok, %{body: results}} = Client.search(index.index_name(), index.doc_types(), query)
      %{search | __raw_results: results}
    end
  end

  @doc """
  Parse elasticsearch results for ids, pass to function for loading.
  """
  def load_results(search, load_fun) do
    case search.__raw_results["hits"]["hits"] do
      hits when is_list(hits) ->
        results = load_fun.(Enum.map(hits, &(String.to_integer(&1["_id"]))))
        %{search | results: results}
      _ -> search
    end
  end

  @doc """
  Add next page pagination info based on the raw results
  """
  def set_next_page(search) do
    total_count = search.__raw_results["hits"]["total"] || 0
    total_pages = round(Float.ceil(total_count / search.per_page))
    next_page = if search.page < total_pages, do: search.page + 1, else: nil

    %{search |
      next_page:               next_page,
      total_count:             total_count,
      total_pages:             total_pages,
      total_pages_remaining:   total_pages - search.page}
  end
end
