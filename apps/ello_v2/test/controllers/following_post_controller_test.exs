defmodule Ello.V2.FollowingPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "GET /v2/following/posts/recent", %{conn: conn} do
    response = get(conn, following_post_path(conn, :index))
    assert response.status == 200
  end

end
