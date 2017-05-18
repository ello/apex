defmodule Ello.Search.TrendingPost do

  def build_boosting_queries(query, trending, following, category) do
    query
    |> boost_recent(trending, following, category)
    |> boost_comment_count(trending)
    |> boost_repost_count(trending)
    |> boost_view_count(trending)
    |> boost_love_count(trending)
    |> update_score_mode(trending)
  end

  defp boost_recent(query, true, nil, nil) do
    weight = Application.get_env(:ello_search, :post_trending_recency_weight)
    scale = Application.get_env(:ello_search, :post_trending_recency_scale)
    offset = Application.get_env(:ello_search, :post_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_in(query[:query][:function_score][:functions], &([recent_boost | &1]))
  end
  defp boost_recent(query, true, true, nil) do
    weight = Application.get_env(:ello_search, :following_trending_recency_weight)
    scale = Application.get_env(:ello_search, :following_trending_recency_scale)
    offset = Application.get_env(:ello_search, :following_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_in(query[:query][:function_score][:functions], &([recent_boost | &1]))
  end
  defp boost_recent(query, true, nil, _) do
    weight = Application.get_env(:ello_search, :category_trending_recency_weight)
    scale = Application.get_env(:ello_search, :category_trending_recency_scale)
    offset = Application.get_env(:ello_search, :category_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_in(query[:query][:function_score][:functions], &([recent_boost | &1]))
  end
  defp boost_recent(query, _, _, _), do: update_in(query[:sort], &(&1 = %{created_at: %{order: "desc"}}))

  defp boost_comment_count(query, true) do
    factor = Application.get_env(:ello_search, :post_trending_comment_boost)
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "comment_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_comment_count(query, _), do: query

  defp boost_repost_count(query, true) do
    factor = Application.get_env(:ello_search, :post_trending_repost_boost)
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "repost_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_repost_count(query, _), do: query

  defp boost_view_count(query, true) do
    factor = Application.get_env(:ello_search, :post_trending_view_boost)
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "view_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_view_count(query, _), do: query

  defp boost_love_count(query, true) do
    factor = Application.get_env(:ello_search, :post_trending_love_boost)
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "love_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_love_count(query, _), do: query

  defp update_score_mode(query, true), do:
    update_in(query[:query][:function_score][:score_mode], &(&1 = "multiply"))
  defp update_score_mode(query, _), do: query

end
