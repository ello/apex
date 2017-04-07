defmodule Ello.Search.Client do

  def search(index_name, doc_types, query) do
    Elastix.Search.search(es_url(), add_prefix(index_name), doc_types, query)
  end

  defp es_url, do: Application.get_env(:ello_search, :es_url)

  defp es_prefix, do: Application.get_env(:ello_search, :es_prefix)

  defp add_prefix(index_name) do
    case es_prefix() do
      nil -> index_name
        _ -> es_prefix() <> index_name
    end
  end
end
