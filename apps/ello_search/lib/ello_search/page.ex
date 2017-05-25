defmodule Ello.Search.Page do

  def pagination_builder(search_struct) do
    page        = search_struct.page
    per_page    = search_struct.per_page
    total_count = search_struct.__raw_results["hits"]["total"] || 0
    total_pages = round(Float.ceil(total_count / per_page))

    %{search_struct |
      page:                    page,
      next_page:               page + 1,
      per_page:                per_page,
      total_count:             total_count,
      total_pages:             total_pages,
      total_pages_remaining:   total_pages - page}
  end

end
