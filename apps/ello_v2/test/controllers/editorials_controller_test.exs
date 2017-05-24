defmodule Ello.V2.EditorialControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Core.Repo

  setup %{conn: conn} do
    e1 = Factory.insert(:post_editorial, published_position: 1, preview_position: 1)
    e2 = Factory.insert(:post_editorial, published_position: nil, preview_position: 3)
    e3 = Factory.insert(:external_editorial, published_position: 2, preview_position: 2)
    e4 = Factory.insert(:category_editorial, published_position: 3, preview_position: 4)
    e5 = Factory.insert(:curated_posts_editorial, published_position: 4, preview_position: 5)
    e6 = Factory.insert(:external_editorial, published_position: nil, preview_position: 6)
    e7 = Factory.insert(:post_editorial, published_position: 5, preview_position: 7)
    user  = Factory.insert(:user)
    staff = Factory.insert(:user, is_staff: true)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    {:ok, [
      conn: auth_conn(conn, user),
      public_conn: public_conn(conn),
      staff_conn: auth_conn(conn, staff),
      editorials: [e1, e2, e3, e4, e5, e6, e7]
    ]}
  end

  test "GET /v2/categories - published", %{conn: conn, editorials: editorials} do
    [_e1, _e2, e3, e4, e5, _e6, e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{per_page: "4"})
    assert %{
      "editorials" => response,
      "linked" => %{
        "posts" => [%{}],
        "users" => [%{}],
      }
    } = json_response(conn, 200)

    assert Enum.map(response, &(String.to_integer(&1["id"]))) ==
      [e7.id, e5.id, e4.id, e3.id]

    assert [
      "<https://ello.co/api/v2/editorials?before=2&per_page=4>;" <> _
    ] = get_resp_header(conn, "link")
  end

  test "GET /v2/categories - published - page2", %{conn: conn, editorials: editorials} do
    [e1, _e2, _e3, _e4, _e5, _e6, _e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{before: "2", per_page: "4"})
    assert %{"editorials" => response} = json_response(conn, 200)
    assert Enum.map(response, &(String.to_integer(&1["id"]))) ==
      [e1.id]
  end

  test "GET /v2/categories - logged out", %{public_conn: conn, editorials: editorials} do
    [_e1, _e2, e3, e4, e5, _e6, e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{per_page: "4"})
    assert %{
      "editorials" => response,
      "linked" => %{
        "posts" => [%{}],
        "users" => [%{}],
      }
    } = json_response(conn, 200)

    assert Enum.map(response, &(String.to_integer(&1["id"]))) ==
      [e7.id, e5.id, e4.id, e3.id]

    assert [
      "<https://ello.co/api/v2/editorials?before=2&per_page=4>;" <> _
    ] = get_resp_header(conn, "link")
  end

  test "GET /v2/categories - preview - not staff", %{conn: conn, editorials: editorials} do
    [_e1, _e2, e3, e4, e5, _e6, e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{preview: "true", per_page: "4"})
    assert %{"editorials" => response} = json_response(conn, 200)
    assert Enum.map(response, &(String.to_integer(&1["id"]))) ==
      [e7.id, e5.id, e4.id, e3.id]

    assert [
      "<https://ello.co/api/v2/editorials?before=2&per_page=4>;" <> _
    ] = get_resp_header(conn, "link")
  end

  test "GET /v2/categories - preview - as staff", %{staff_conn: conn, editorials: editorials} do
    [_e1, _e2, _e3, e4, e5, e6, e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{preview: "true", per_page: "4"})
    assert %{"editorials" => response} = json_response(conn, 200)
    assert Enum.map(response, &(String.to_integer(&1["id"]))) ==
      [e7.id, e6.id, e5.id, e4.id]

    assert [
      "<https://ello.co/api/v2/editorials?before=4&per_page=4&preview=true>;" <> _
    ] = get_resp_header(conn, "link")
  end

  test "GET /v2/categories - first page", %{public_conn: conn} do
    conn = get(conn, editorial_path(conn, :index), %{per_page: "4"})
    assert ["1"] = get_resp_header(conn, "x-total-pages-remaining")
  end

  test "GET /v2/categories - last page", %{public_conn: conn, editorials: editorials} do
    [_e1, _e2, _e3, _e4, e5, _e6, _e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{per_page: "4", before: "#{e5.published_position}"})
    assert ["0"] = get_resp_header(conn, "x-total-pages-remaining")
  end

  test "GET /v2/categories - too many pages", %{public_conn: conn, editorials: editorials} do
    [e1, _e2, _e3, _e4, _e5, _e6, _e7] = editorials
    conn = get(conn, editorial_path(conn, :index), %{per_page: "4", before: "#{e1.published_position}"})
    assert response(conn, 204)
    assert ["0"] = get_resp_header(conn, "x-total-pages-remaining")
  end
end
