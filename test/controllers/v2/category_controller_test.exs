defmodule Ello.V2.CategoryControllerTest do
  use Ello.ConnCase
  alias Ello.Category

  setup %{conn: conn} do
    Repo.insert(featured)
    Repo.insert(development)
    Repo.insert(design)
    archer = Repo.insert!(archer)

    {:ok, conn: auth_conn(conn, archer)}
  end

  test "GET /v2/categories/:slug", %{conn: conn} do
    conn = get(conn, v2_category_path(conn, :show, "featured"))
    assert %{"name" => "Featured"} = json_response(conn, 200)["categories"]
  end

  test "GET /v2/categories?all=true", %{conn: conn} do
    conn = get(conn, v2_category_path(conn, :index), %{all: true})
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.map(categories, &(&1["name"])) == ["Featured", "Development", "Design"]
  end

  test "GET /v2/categories?meta=true", %{conn: conn} do
    conn = get(conn, v2_category_path(conn, :index), %{meta: true})
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.map(categories, &(&1["name"])) == ["Development", "Featured"]
  end

  test "GET /v2/categories", %{conn: conn} do
    conn = get(conn, v2_category_path(conn, :index))
    assert %{"categories" => categories} = json_response(conn, 200)
    assert Enum.map(categories, &(&1["name"])) == ["Development"]
  end

  defp featured do
    %Category{
      name: "Featured",
      slug: "featured",
      cta_caption: nil,
      cta_href: nil,
      description: nil,
      is_sponsored: false,
      level: "meta",
      order: 0,
      uses_page_promotionals: true,
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  defp development do
    %Category{
      name: "Development",
      slug: "development",
      cta_caption: nil,
      cta_href: nil,
      description: "All thing dev related",
      is_sponsored: false,
      level: "Primary",
      order: 0,
      uses_page_promotionals: false,
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  defp design do
    %Category{
      name: "Design",
      slug: "design",
      cta_caption: nil,
      cta_href: nil,
      description: "All thing design related",
      is_sponsored: false,
      level: nil,
      order: 0,
      uses_page_promotionals: false,
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  defp archer do
    %Ello.User{
      username: "archer",
      name: "Sterling Archer",
      location: "New York, NY",
      email_hash: "not used"
    }
  end
end
