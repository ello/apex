defmodule Ello.V2.CategoryControllerTest do
  use Ello.V2.ConnCase

  setup %{conn: conn} do
    Script.insert(:featured_category)
    Script.insert(:lacross_category)
    brand_user = Factory.insert(:user, username: "brandy")
    design = Factory.insert(:category, name: "Design", slug: "design", is_creator_type: true)
    branded = Factory.insert(:category, name: "Branded", slug: "branded", brand_account: brand_user)
    spying = Script.insert(:espionage_category)
    archer = Script.insert(:archer)
    Factory.insert(:category_user, user: archer, category: spying)
    {:ok, conn: auth_conn(conn, archer), unauth_conn: conn, spying: spying, design: design, brand_user: brand_user, branded: branded}
  end

  test "GET /v2/categories/:slug - without token", %{unauth_conn: conn} do
    conn = get(conn, category_path(conn, :show, "featured"))
    assert conn.status == 401
  end

  test "GET /v2/categories/:slug", %{conn: conn} do
    conn = get(conn, category_path(conn, :show, "featured"))
    assert %{"name" => "Featured"} = json_response(conn, 200)["categories"]
  end

  test "GET /v2/categories/:slug - brand account", %{conn: conn, brand_user: %{id: user_id, username: username}, branded: branded} do
    conn = get(conn, category_path(conn, :show, branded.slug))
    response = json_response(conn, 200)
    user_id_str = "#{user_id}"
    assert %{"links" => %{"brand_account" => %{"id" => ^user_id_str}}} = response["categories"]
    assert %{"brand_account" => %{"username" => ^username}} = response["linked"]
  end

  test "GET /v2/categories/:slug - 404", %{conn: conn} do
    conn = get(conn, category_path(conn, :show, "nopenopenope"))
    assert conn.status == 404
  end

  test "GET /v2/categories/:slug - 304", %{conn: conn} do
    resp = get(conn, category_path(conn, :show, "featured"))
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(category_path(conn, :show, "featured"))
    assert resp2.status == 304
  end

  test "GET /v2/categories?all=true", %{conn: conn} do
    conn = get(conn, category_path(conn, :index), %{all: true})
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.member?(category_names(categories), "Lacross") == true
    assert Enum.member?(category_names(categories), "Featured") == true
    assert Enum.member?(category_names(categories), "Espionage") == true
  end

  test "GET /v2/categories?all=true - 304", %{conn: conn, spying: cat} do
    resp = get(conn, category_path(conn, :index), %{all: true})
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(category_path(conn, :index), %{all: true})
    assert resp2.status == 304
    Factory.insert(:promotional, category: cat)
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(category_path(conn, :index), %{all: true})
    assert resp3.status == 200
  end

  test "GET /v2/categories?meta=true", %{conn: conn} do
    conn = get(conn, category_path(conn, :index), %{meta: true})
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.member?(category_names(categories), "Lacross") == true
    assert Enum.member?(category_names(categories), "Featured") == true
  end

  test "GET /v2/categories", %{conn: conn} do
    conn = get(conn, category_path(conn, :index))
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.member?(category_names(categories), "Lacross") == true
  end

  @tag :json_schema
  test "GET /v2/categories?all=true - json schema", %{conn: conn} do
    conn = get(conn, category_path(conn, :index), %{all: true})
    assert :ok = validate_json("category", json_response(conn, 200))
  end

  @tag :json_schema
  test "GET /v2/categories/:slug - json schema", %{conn: conn} do
    conn = get(conn, category_path(conn, :show, "featured"))
    assert :ok = validate_json("category", json_response(conn, 200))
  end

  test "GET /v2/categories?creator_types=true", %{conn: conn} do
    conn = get(conn, category_path(conn, :index), %{creator_types: true})
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.member?(category_names(categories), "Design") == true
    assert Enum.member?(category_names(categories), "Lacross") == false
    assert Enum.member?(category_names(categories), "Featured") == false
  end

  test "GET /v2/categories?creator_types=true - 304", %{conn: conn, design: cat} do
    resp = get(conn, category_path(conn, :index), %{creator_types: true})
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(category_path(conn, :index), %{creator_types: true})
    assert resp2.status == 304
    Factory.insert(:promotional, category: cat)
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(category_path(conn, :index), %{creator_types: true})
    assert resp3.status == 200
  end

  defp category_names(categories) do
    Enum.map(categories, &(&1["name"]))
  end
end
