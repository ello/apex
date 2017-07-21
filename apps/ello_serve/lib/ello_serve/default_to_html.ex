defmodule Ello.Serve.DefaultToHTML do
  @moduledoc """
  Adds the accepts `*/*` header if the request has no accept header.

  This ensures even clients not sending accepts headers get responses.
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case get_req_header(conn, "accepts") do
      []        -> put_req_header(conn, "accepts", "*/*")
      [accepts] -> put_req_header(conn, "accepts", verify_accepts(accepts))
    end
  end

  defp verify_accepts(accepts) when is_binary(accepts),
    do: verify_accepts(String.split(accepts, ","))
  defp verify_accepts(accepts) do
    if "text/html" in accepts do
      Enum.join(accepts, ",")
    else
      Enum.map_join(accepts, ",", &tweak_format/1)
    end
  end

  defp tweak_format("text/*"), do: "text/html"
  defp tweak_format(other),    do: other
end
