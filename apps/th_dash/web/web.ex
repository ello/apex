defmodule TH.Dash.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use TH.Dash.Web, :controller
      use TH.Dash.Web, :view
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TH.Dash

      import TH.Dash.Router.Helpers
      plug Ello.Auth.RequireToken
      # import Ello.Auth
    end
  end

  def public_controller do
    quote do
      use Phoenix.Controller, namespace: TH.Dash

      import TH.Dash.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", namespace: TH.Dash

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import TH.Dash.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
