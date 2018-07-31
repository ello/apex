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

  test "has a findPosts query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "findPosts" in Enum.map(json, &(&1["name"]))
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

  test "has a categoryNav query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "categoryNav" in Enum.map(json, &(&1["name"]))
  end

  test "has a globalPostStream query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "globalPostStream" in Enum.map(json, &(&1["name"]))
  end

  test "has an allCategories query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "allCategories" in Enum.map(json, &(&1["name"]))
  end

  test "has a category query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "category" in Enum.map(json, &(&1["name"]))
  end

  test "has a categoryPostStream query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "categoryPostStream" in Enum.map(json, &(&1["name"]))
  end

  test "has an editorialStream query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "editorialStream" in Enum.map(json, &(&1["name"]))
  end

  test "has a findUser query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "findUser" in Enum.map(json, &(&1["name"]))
  end

  test "has a notifications query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "notificationStream" in Enum.map(json, &(&1["name"]))
  end

  test "has a new notifications query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "newNotificationStreamContent" in Enum.map(json, &(&1["name"]))
  end

  test "has a searchUsers query" do
    resp = post_graphql(%{query: @query_list_query})
    json = json_response(resp)["data"]["__schema"]["queryType"]["fields"]
    assert "searchUsers" in Enum.map(json, &(&1["name"]))
  end
end
