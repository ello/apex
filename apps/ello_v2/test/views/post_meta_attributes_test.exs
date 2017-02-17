defmodule Ello.V2.PostMetaAttributesViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.PostMetaAttributesView
  alias Ello.Core.Content.{Asset}

  setup %{conn: conn} do
    archer = Script.build(:archer)
    asset1 = Factory.build(:asset, %{id: 1}) |> Asset.build_attachment
    asset2 = Factory.build(:asset, %{id: 2}) |> Asset.build_attachment
    post = Factory.build(:post, %{
      id: 1,
      author: archer,
      assets: [asset1, asset2],
      body: [ %{"kind" => "text", "data" => "Phrasing!"},
              %{"kind" => "embed", "data" => %{"url" => "www.youtube.com/archer"}}],
      reposted_source: nil,
      repost_from_current_user: nil,
      love_from_current_user: nil,
      watch_from_current_user: nil,
    })
    bad_for_seo_post = Factory.build(:post, %{
      id: 1,
      author: Map.put(archer, :bad_for_seo, true),
      assets: [asset1, asset2],
      body: [ %{"kind" => "text", "data" => "Phrasing!"},
              %{"kind" => "embed", "data" => %{"url" => "www.youtube.com/archer"}}],
      reposted_source: nil,
      repost_from_current_user: nil,
      love_from_current_user: nil,
      watch_from_current_user: nil,
    })
    repost = Factory.build(:post, %{
      id: 2,
      author: archer,
      reposted_source: post,
      assets: []
    })
    {:ok, conn: conn, post: post, bad_for_seo_post: bad_for_seo_post, repost: repost}
  end

  test "post.json - it renders meta attributes for a post", %{post: post} do
    assert %{
      description: "Phrasing!",
      images: ["https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg",
               "https://assets.ello.co/uploads/asset/attachment/2/ello-hdpi-081e2121.jpg"],
      embeds: ["www.youtube.com/archer"],
      robots: "index, follow",
      title: "test post",
      url: "https://ello.co/archer/post/#{post.token}",
      canonical_url: nil,
    } == render(PostMetaAttributesView, "post.json", post: post)
  end

  test "post.json - it renders the description correctly if there is no body text", %{post: post} do
    post = Map.put(post, :body, [])
    assert %{
      description: "Discover more amazing work like this on Ello.",
      images: ["https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg",
               "https://assets.ello.co/uploads/asset/attachment/2/ello-hdpi-081e2121.jpg"],
      embeds: nil,
      robots: "index, follow",
      title: "test post",
      url: "https://ello.co/archer/post/#{post.token}",
      canonical_url: nil,
    } == render(PostMetaAttributesView, "post.json", post: post)
  end

  test "post.json - it renders the embeds correctly if there are no embeds", %{post: post} do
    post = Map.put(post, :body, [%{"kind" => "text", "data" => "Phrasing!"}])
    assert %{
      description: "Phrasing!",
      images: ["https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg",
               "https://assets.ello.co/uploads/asset/attachment/2/ello-hdpi-081e2121.jpg"],
      embeds: nil,
      robots: "index, follow",
      title: "test post",
      url: "https://ello.co/archer/post/#{post.token}",
      canonical_url: nil,
    } == render(PostMetaAttributesView, "post.json", post: post)
  end

  test "post.json - it renders the robots correctly if the author is bad for seo", %{bad_for_seo_post: post} do
    assert %{
      description: "Phrasing!",
      images: ["https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg",
               "https://assets.ello.co/uploads/asset/attachment/2/ello-hdpi-081e2121.jpg"],
      embeds: ["www.youtube.com/archer"],
      robots: "noindex, follow",
      title: "test post",
      url: "https://ello.co/archer/post/#{post.token}",
      canonical_url: nil,
    } == render(PostMetaAttributesView, "post.json", post: post)
  end

  test "post.json - it renders the canonical_url correctly if the post is a repost", %{repost: repost, post: post} do
    assert %{
      description: "Phrasing!",
      images: [],
      embeds: nil,
      robots: "index, follow",
      title: "test post",
      url: "https://ello.co/archer/post/#{repost.token}",
      canonical_url: "https://ello.co/archer/post/#{post.token}",
    } == render(PostMetaAttributesView, "post.json", post: repost)
  end
end
