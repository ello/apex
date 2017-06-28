defmodule Ello.Serve.StandardParams do
  alias Plug.Conn
  @max_page_size 50

  def standard_params(%Conn{params: params}, overrides \\ %{}) do
    Map.merge(%{
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,

      before:       before(params),
      per_page:     per_page(params, overrides[:default][:per_page]),
      page:         page(params),
    }, overrides)
  end

  defp before(%{"before" => before}), do: before
  defp before(_), do: nil

  defp page(%{"page" => ""}), do: 1
  defp page(%{"page" => nil}), do: 1
  defp page(%{"page" => page}), do: String.to_integer(page)
  defp page(_), do: 1

  defp per_page(%{"per_page" => nil}, nil), do: 25
  defp per_page(%{"per_page" => nil}, default), do: default
  defp per_page(%{"per_page" => ""}, nil), do: 25
  defp per_page(%{"per_page" => ""}, default), do: default
  defp per_page(%{"per_page" => per_page}, _) do
    min(String.to_integer(per_page), @max_page_size)
  end
  defp per_page(_, nil), do: 25
  defp per_page(_, default), do: default
end
