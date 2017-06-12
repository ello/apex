defmodule Ello.Search.Client do
  alias Elastix.{
    Search,
    Index,
    Mapping,
    Document,
  }

  def search(index_name, doc_types, query), do:
    Search.search(es_url(), add_prefix(index_name), doc_types, query)

  def aws_search(index_name, doc_types, query), do:
    Search.search(aws_es_url(), add_prefix(index_name), doc_types, query)

  def create_index(index_name, settings), do:
    Index.create(es_url(), add_prefix(index_name), settings)

  def delete_index(index_name), do:
    Index.delete(es_url(), add_prefix(index_name))

  def put_mapping(index_name, doc_type, mapping), do:
    Mapping.put(es_url(), add_prefix(index_name), doc_type, mapping)

  def index_document(index_name, doc_type, id, index_data, query_params \\ %{}), do:
    Document.index(es_url(), add_prefix(index_name), doc_type, id, index_data, query_params)

  def refresh_index(index_name), do:
    Index.refresh(es_url(), add_prefix(index_name))

  def headers(%{url: url, headers: headers} = request) do
    if String.contains?(url, "es.amazonaws.com") do
      {:ok, headers} = auth_header(request)
      headers
    else
      headers
    end
  end

  defp auth_header(request) do
    ExAws.Auth.headers(request.method, request.url, :es, aws_creds(), request.headers, request.body)
  end

  defp es_url, do: Application.get_env(:ello_search, :es_url)
  defp aws_es_url, do: Application.get_env(:ello_search, :aws_es_url)

  defp es_prefix, do: Application.get_env(:ello_search, :es_prefix)

  defp add_prefix(index_name) do
    case es_prefix() do
      nil -> index_name
        _ -> es_prefix() <> "_" <> index_name
    end
  end

  # Note: There isn't support for ES built into ExAws, so we use "s3" default
  # config. It is really only used to determine region and get signing
  # credentials.
  defp aws_creds do
    ExAws.Config.new(:s3)
  end
end
