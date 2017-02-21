defmodule Ello.Auth do

  @doc """
  If present, gets the current user from a %Plug.Conn{}
  """
  def current_user(%Plug.Conn{assigns: %{current_user: user}}), do: user
  def current_user(_), do: nil

  def can_view_user?(%Plug.Conn{assigns: %{current_user: user}},
                      %{locked_at: nil} = user) do
    not user.id in user.all_blocked_ids
  end
  def can_view_user?(_, nil), do: false
  def can_view_user?(_, %{is_public: false}), do: false
  def can_view_user?(_, %{locked_at: nil}), do: true
  def can_view_user?(_, _), do: false
end
