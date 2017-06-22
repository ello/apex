defmodule Ello.Serve.SkipPrerender do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    assign(conn, :prerender, prerender?(conn))
  end

  defp prerender?(%{params: %{"prerender" => "false"}}) do
    false
  end
  defp prerender?(_), do: true
end
