defmodule Ello.V2.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Ello.V3.Web, :controller
      use Ello.V2.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      # Define common model functionality
    end
  end

  def public_controller do
    quote do
      use Phoenix.Controller, namespace: Ello.V2

      import Ello.V2.Router.Helpers
      import Ello.V2.Gettext
    end
  end

  def controller do
    quote do
      unquote(public_controller())
      plug Ello.Auth.RequireToken
      plug Ello.Auth.ClientProperties
      import Ello.Auth
      import Ello.V2.PostViewTracking
      import Ello.V2.Render
      import Ello.V2.Pagination
      import Ello.V2.StandardParams
      alias Ello.V2.Manage
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", namespace: Ello.V2

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
      import Ello.V2.ConditionalGet, only: [etag: 1]

      import Ello.V2.Router.Helpers
      import Ello.V2.ErrorHelpers
      import Ello.V2.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Ello.V2.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
