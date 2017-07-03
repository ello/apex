defmodule Ello.Serve.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Ello.Serve.Web, :controller
      use Ello.Serve.Web, :view

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

  def controller do
    quote do
      use Phoenix.Controller, namespace: Ello.Serve

      import Ello.Serve.Router.Helpers
      import Ello.Serve.Gettext
      import Ello.Serve.Render
      import Ello.Serve.StandardParams

      import Ello.Events.TrackPostViews, only: [track: 2, track: 3]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", namespace: Ello.Serve

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Ello.Serve.Router.Helpers
      import Ello.Serve.ErrorHelpers
      import Ello.Serve.Gettext
      import Ello.Serve.WebappHelpers
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
      import Ello.Serve.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
