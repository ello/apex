defmodule Ello.Core.Content do
  alias Ello.Core.{
    Repo,
    Redis,
  }
  alias __MODULE__.{
    Post,
  }

  @spec post(id_or_slug :: String.t | integer, current_user :: User.t | nil) :: Post.t
  def post(id_or_slug, current_user \\ nil)
  def post("~" <> slug, current_user) do
    Post
    |> Repo.get_by(token: slug)
  end
  def post(id, current_user) do
    Post
    |> Repo.get(id)
  end
end
