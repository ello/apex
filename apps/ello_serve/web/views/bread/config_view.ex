defmodule Ello.Serve.Bread.ConfigView do
  use Ello.Serve.Web, :view

  def encoded_env(conn) do
    conn
    |> bread_env()
    |> set_debug(conn)
    |> Poison.encode!
    |> URI.encode
  end

  defp bread_env(_conn) do
    Enum.reduce Application.get_env(:ello_serve, :bread_config), %{}, fn
      ({_, nil}, acc)   -> acc
      ({key, val}, acc) -> Map.put(acc, String.upcase(Atom.to_string(key)), val)
    end
  end

  def set_debug(env, %{assigns: %{debug: true}}),
    do: Map.put(env, "APP_DEBUG", true)
  def set_debug(env, %{assigns: %{debug: false}}),
    do: Map.put(env, "APP_DEBUG", false)
  def set_debug(env, _), do: env
end
