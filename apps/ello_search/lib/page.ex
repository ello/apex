defmodule Ello.Search.Page do

  defstruct [
    results:      [],
    raw:          %{},
    per_page:     25,
    current_page: 1,
    next_page:    2,
    total_count:  nil,
    total_pages:  nil,
    total_pages_remaining: nil,
    terms:        nil,
  ]

  def from_results(raw_results, models, opts) do
    page        = String.to_integer(opts[:page] || "1")
    per_page    = String.to_integer(opts[:per_page] || "25")
    total_count = raw_results["hits"]["total"]
    total_pages = round(Float.ceil(total_count / per_page))

    %__MODULE__{
      results:      models,
      raw:          raw_results,
      terms:        opts[:terms],
      current_page: page,
      next_page:    page + 1,
      per_page:     per_page,
      total_count:  total_count,
      total_pages:  total_pages,
      total_pages_remaining: total_pages - page,
    }
  end

end
