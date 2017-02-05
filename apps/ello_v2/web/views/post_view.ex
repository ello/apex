defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view

  def render("show.json", %{post: post, conn: conn}) do
    %{
      posts: render_one(post, __MODULE__, "post.json", conn: conn),
    }
  end

  def render("post.json", %{post: post, conn: conn}) do
    %{
      id: "#{post.id}"
    }
  end
end
