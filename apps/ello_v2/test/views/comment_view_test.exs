defmodule Ello.V2.CommentViewTest do
  use Ello.V2.ConnCase, async: true
  alias Ello.V2.CommentView

  setup %{conn: conn} do
    post = Factory.insert(:post, assets: [])
    author = Factory.insert(:user)
    comment = Factory.insert(:post, %{
      parent_post: post,
      author:      author,
      assets:      [],
    })
    comment2 = Factory.insert(:post, %{
      parent_post: post,
      assets:      [],
    })
    conn = assign(conn, :post, post)
    {:ok, [
      conn:        conn,
      author_conn: user_conn(conn, author),
      comment:     comment,
      comment2:    comment2,
    ]}
  end

  test "show.json", context do
    json = CommentView.render("show.json", %{
      conn: context[:conn],
      data: context[:comment],
    })
    assert json[:comments][:id] == "#{context[:comment].id}"
    assert json[:linked][:users]
    assert json[:linked][:parent_post]
  end

  test "index.json", context do
    json = CommentView.render("index.json", %{
      conn: context[:conn],
      data: [context[:comment], context[:comment2]],
    })
    assert [_, _] = json[:comments]
    assert json[:linked][:users]
    assert json[:linked][:parent_post]
  end

  test "comment.json - as author", context do
    json = CommentView.render("comment.json", %{
      conn:    context[:author_conn],
      comment: context[:comment],
    })
    assert json[:body]
    assert json[:id]
    assert json[:summary]
    assert json[:content]
  end

  test "comment.json - not author", context do
    json = CommentView.render("comment.json", %{
      conn:    context[:conn],
      comment: context[:comment],
    })
    assert json[:body] == []
    assert json[:id]
    assert json[:summary]
    assert json[:content]
  end
end
