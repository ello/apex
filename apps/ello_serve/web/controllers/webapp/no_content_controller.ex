defmodule Ello.Serve.Webapp.NoContentController do
  use Ello.Serve.Web, :controller

  def show(conn, _) do
    render_html(conn)
  end

  def enter(conn, _) do
    render_html(conn, %{
      title: "Login | Ello",
      description: "Welcome back to Ello. Sign in now to publish, share and promote your work and ideas, check your notifications, and collaborate.",
    })
  end

  def join(conn, _) do
    render_html(conn, %{
      title: "Sign up | Ello",
      description: "Join the Creators Network. Ello is a networked marketplace and publishing platform providing creators visibility, influence and opportunity.",
    })
  end

  def forgot(conn, _) do
    render_html(conn, %{
      title: "Forgot Password | Ello",
      description: "Welcome back to Ello. Enter your email to reset your password.",
    })
  end
end
