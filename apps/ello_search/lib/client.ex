defmodule Ello.Search.Client do
  alias Elastix.{
    Search,
    Index,
    Mapping,
    Document,
  }

  def search(index_name, doc_types, query), do:
    Search.search(es_url(), add_prefix(index_name), doc_types, query)

  def create_index(index_name, settings), do:
    Index.create(es_url(), add_prefix(index_name), settings)

  def delete_index(index_name), do:
    Index.delete(es_url(), add_prefix(index_name))

  def put_mapping(index_name, doc_type, mapping), do:
    Mapping.put(es_url(), add_prefix(index_name), doc_type, mapping)

  def index_document(index_name, doc_type, id, index_data), do:
    Document.index(es_url(), add_prefix(index_name), doc_type, id, index_data)

  def refresh_index(index_name), do:
    Index.refresh(es_url(), add_prefix(index_name))

  defp es_url, do: Application.get_env(:ello_search, :es_url)

  defp es_prefix, do: Application.get_env(:ello_search, :es_prefix)

  defp add_prefix(index_name) do
    case es_prefix() do
      nil -> index_name
        _ -> es_prefix() <> index_name
    end
  end

end
