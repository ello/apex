defmodule Ello.V3.Resolvers.CategoryUsers do
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Network.User

  # Assuming preloaded category_users on category, with roles taken into account
  def call(%Category{category_users: cusers}, _args, _resolution) when is_list(cusers) do
    {:ok, cusers}
  end
  def call(%Category{id: _id}, _args, _resolution), do: {:ok, []}
  def call(%User{category_users: cusers}, _args, _resolution) when is_list(cusers) do
    {:ok, cusers}
  end
  def call(%User{id: _id}, _args, _resolution), do: {:ok, []}
end
