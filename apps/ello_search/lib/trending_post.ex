defmodule Ello.Search.TrendingPost do

  def build_match_all_query(query), do:
    update_in(query[:query][:function_score][:query][:bool][:must], &([%{match_all: %{}} | &1]))

  def build_boosting_queries(query) do
    query
    |> build_view_count_query
    |> build_love_count_query
    |> build_comment_count_query
    |> build_repost_count_query
    |> build_decay_function
  end

  def base_query do
    %{
      from: 0,
      size: 10,
      stored_fields: [],
      query: %{
        function_score: %{
          query: %{
            bool: %{
              must:     [],
              should:   [],
              filter:   [],
              must_not: []
            }
          },
          functions: [],
          score_mode: "sum",
          boost_mode: "sum"
        }
      }
    }
  end

  defp build_view_count_query(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "view_count", modifier: "log1p", factor: 0.00001}} | &1]))

  defp build_love_count_query(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "love_count", modifier: "log1p", factor: 0.05}} | &1]))

  defp build_comment_count_query(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "comment_count", modifier: "log1p", factor: 0.3}} | &1]))

  defp build_repost_count_query(query), do:
    update_in(query[:query][:function_score][:functions], &([%{field_value_factor: %{field: "repost_count", modifier: "log1p", factor: 0.8}} | &1]))

  defp build_decay_function(query), do:
    update_in(query[:query][:function_score][:functions], &([%{gauss: %{created_at: %{scale: "3h", offset: "1d"}}, weight: 1} | &1]))
end
