defmodule Ello.V3.SchemaTest do
  use Ello.V3.Case

  @query_list_query """
    {
      __schema {
        queryType {
          name
          fields {
            name
          }
        }
      }
    }
  """

  test "has a post query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "post" in Enum.map(json, &(&1["name"]))
  end

  test "has a userPostStream query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "userPostStream" in Enum.map(json, &(&1["name"]))
  end

  test "has a pageHeaders query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "pageHeaders" in Enum.map(json, &(&1["name"]))
  end
end
