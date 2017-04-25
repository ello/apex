defmodule Ello.Search.TrendingPost do

  def build_boosting_queries(query, trending) do
    query
    |> boost_recent(trending)
    |> boost_comment_count(trending)
    |> boost_repost_count(trending)
    |> boost_view_count
    |> boost_love_count
    |> update_score_mode(trending)
  end

  defp boost_recent(query, true) do
    recent_boost = %{gauss: %{created_at: %{scale: "3h", offset: "1d"}}, weight: 1}
    update_in(query[:query][:function_score][:functions], &([recent_boost | &1]))
  end
  defp boost_recent(query, _) do
    recent_boost = %{gauss: %{created_at: %{scale: "3d", offset: "1d"}}, weight: 1000}
    update_in(query[:query][:function_score][:functions], &([recent_boost | &1]))
  end

  defp boost_comment_count(query, true), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "comment_count", modifier: "log1p", factor: 0.3}} | &1]))
  defp boost_comment_count(query, _), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "comment_count", modifier: "log1p", factor: 0.01}} | &1]))

  defp boost_repost_count(query, true), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "repost_count", modifier: "log1p", factor: 0.8}} | &1]))
  defp boost_repost_count(query, _), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "repost_count", modifier: "log1p", factor: 0.1}} | &1]))

  defp boost_view_count(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "view_count", modifier: "log1p", factor: 0.00001}} | &1]))

  defp boost_love_count(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "love_count", modifier: "log1p", factor: 0.05}} | &1]))

  defp update_score_mode(query, true), do:
    update_in(query[:query][:function_score][:score_mode], &(&1 = "multiply"))
  defp update_score_mode(query, _), do: query

end
