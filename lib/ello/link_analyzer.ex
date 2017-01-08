defmodule Ello.LinkAnalyzer do
  def format_links_for_serialization(links) do
    links
      |> Enum.map(fn link ->
          url  = sanitize_url(link)
          text = sanitize_text(link)
          icon = match_url_to_icon(url) || %{}
          Map.merge(%{ url: url, text: text }, icon)
      end)
  end

  defp sanitize_url(link) do
    cond do
      String.match?(link, ~r/\Ahttp/i) -> link
      true -> "http://" <> link
    end
  end

  defp sanitize_text(link), do: String.replace(link, ~r/\Ahttps?:\/\//i, "")
  defp match_url_to_icon(link), do: IconType.match(link)
end
