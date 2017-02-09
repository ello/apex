defmodule Ello.Core.Content do
  alias Ello.Core.{
    Repo,
    Redis,
    Network,
  }
  alias __MODULE__.{
    Post,
  }

  @spec post(id_or_slug :: String.t | integer, current_user :: User.t | nil) :: Post.t
  def post(id_or_slug, current_user \\ nil)
  def post("~" <> slug, current_user) do
    Post
    |> Repo.get_by(token: slug)
    |> post_preloads(current_user)
  end
  def post(id, current_user) do
    Post
    |> Repo.get(id)
    |> post_preloads(current_user)
  end

  defp post_preloads(post_or_posts, current_user) do
    Repo.preload(post_or_posts, author: &Network.users(&1, current_user))
  end
end
