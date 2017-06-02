defmodule Ello.Search.Post.Trending do

  def build_boosting_queries(search_struct) do
    search_struct
    |> boost_recent
    |> boost_comment_count
    |> boost_repost_count
    |> boost_view_count
    |> boost_love_count
    |> update_score_mode
  end

  defp boost_recent(%{trending: true, following: false, category: nil} = search_struct) do
    weight = Application.get_env(:ello_search, :post_trending_recency_weight)
    scale = Application.get_env(:ello_search, :post_trending_recency_scale)
    offset = Application.get_env(:ello_search, :post_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_function_score(search_struct, :functions, &([recent_boost | &1]))
  end
  defp boost_recent(%{trending: true, following: true, category: nil} = search_struct) do
    weight = Application.get_env(:ello_search, :following_trending_recency_weight)
    scale = Application.get_env(:ello_search, :following_trending_recency_scale)
    offset = Application.get_env(:ello_search, :following_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_function_score(search_struct, :functions, &([recent_boost | &1]))
  end
  defp boost_recent(%{trending: true, following: false} = search_struct) do
    weight = Application.get_env(:ello_search, :category_trending_recency_weight)
    scale = Application.get_env(:ello_search, :category_trending_recency_scale)
    offset = Application.get_env(:ello_search, :category_trending_recency_offset)
    recent_boost = %{gauss: %{created_at: %{scale: scale, offset: offset}}, weight: weight}
    update_function_score(search_struct, :functions, &([recent_boost | &1]))
  end
  defp boost_recent(search_struct) do
    put_in(search_struct.query[:sort], %{created_at: %{order: "desc"}})
  end

  defp boost_comment_count(%{trending: true} = search_struct) do
    factor = Application.get_env(:ello_search, :post_trending_comment_boost)
    update_function_score(search_struct, :functions, &([%{field_value_factor: %{field: "comment_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_comment_count(search_struct), do: search_struct

  defp boost_repost_count(%{trending: true} = search_struct) do
    factor = Application.get_env(:ello_search, :post_trending_repost_boost)
    update_function_score(search_struct, :functions, &([%{field_value_factor: %{field: "repost_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_repost_count(search_struct), do: search_struct

  defp boost_view_count(%{trending: true} = search_struct) do
    factor = Application.get_env(:ello_search, :post_trending_view_boost)
    update_function_score(search_struct, :functions, &([%{field_value_factor: %{field: "view_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_view_count(search_struct), do: search_struct

  defp boost_love_count(%{trending: true} = search_struct) do
    factor = Application.get_env(:ello_search, :post_trending_love_boost)
    update_function_score(search_struct, :functions, &([%{field_value_factor: %{field: "love_count", modifier: "log1p", factor: factor}} | &1]))
  end
  defp boost_love_count(search_struct), do: search_struct

  defp update_score_mode(%{trending: true} = search_struct) do
    put_in(search_struct.query[:query][:function_score][:score_mode], "multiply")
  end
  defp update_score_mode(search_struct), do: search_struct

  defp update_function_score(struct, key, fun) do
    update_in(struct.query[:query][:function_score][key], fun)
  end
end
