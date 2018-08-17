defmodule Ello.V3.Resolvers.Profile do

  def call(_parent, %{current_user: current_user}, _resolver) do
    {:ok, current_user}
  end

end
