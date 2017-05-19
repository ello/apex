defmodule Ello.V2.StandardParams do
  alias Plug.Conn
  @max_page_size 50

  def standard_params(%Conn{params: params, assigns: assigns}, overrides \\ %{}) do
    Map.merge(%{
      current_user: assigns[:current_user],
      allow_nsfw:   assigns[:allow_nsfw],
      allow_nudity: assigns[:allow_nudity],

      before:       before(params),
      per_page:     per_page(params, overrides[:default][:per_page]),
      page:         page(params),
    }, overrides)
  end

  defp before(%{"before" => before}), do: before
  defp before(_), do: nil

  defp page(%{"page" => page}), do: String.to_integer(page)
  defp page(_), do: 1

  defp per_page(%{"per_page" => per_page}, _) do
    min(String.to_integer(per_page), @max_page_size)
  end
  defp per_page(_, nil), do: 25
  defp per_page(_, default), do: default
end
