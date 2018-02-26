defmodule Ello.V3.Resolvers.PageHeaders do
  alias Ello.Core.Discovery
  @page_promotional_kinds [:artist_invite, :editorial, :generic, :authentication]

  def call(_, %{kind: :category} = args, _) do
    # We always need category to "proxy" header, title, etc
    args = Map.put(args, :preloads, Map.merge(%{category: %{}}, args[:preloads]))
    {:ok, Discovery.promotionals(args)}
  end

  def call(_, %{kind: kind} = args, _) when kind in @page_promotional_kinds do
    {:ok, Discovery.page_promotionals(args)}
  end
end
