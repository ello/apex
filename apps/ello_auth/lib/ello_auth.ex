defmodule Ello.Auth do

  @doc """
  If present, gets the current user from a %Plug.Conn{}
  """
  def current_user(%Plug.Conn{assigns: %{current_user: user}}), do: user
  def current_user(_), do: nil
end
