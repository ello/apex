defmodule Ello.Core do
  @moduledoc """
  Documentation for Ello.Core.
  """

  def parse_before(%DateTime{} = before), do: before
  def parse_before(nil), do: nil
  def parse_before(before) do
    before
    |> URI.decode
    |> DateTime.from_iso8601
    |> case do
      {:ok, date, _} -> date
      _ -> nil
    end
  end
end
