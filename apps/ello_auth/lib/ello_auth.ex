defmodule Ello.Auth do
  @moduledoc """
  All of these methods are imported into V2 Controllers
  """

  @doc """
  If present, gets the current user from a %Plug.Conn{}
  """

  def current_user(%Plug.Conn{assigns: %{current_user: current_user}}),
    do: current_user
  def current_user(_), do: nil

  @doc """
  Returns false if the current user blocks or is blocked by the fetched user.
  """
  def can_view_user?(_, nil), do: false
  def can_view_user?(%{assigns: %{current_user: current_user}},
                      %{locked_at: nil} = user) when not is_nil(current_user) do
    not user.id in current_user.all_blocked_ids
  end
  def can_view_user?(_, %{is_public: false}), do: false
  def can_view_user?(_, %{locked_at: nil}), do: true
  def can_view_user?(_, _), do: false
end
