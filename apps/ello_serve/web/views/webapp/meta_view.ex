defmodule Ello.Serve.Webapp.MetaView do
  use Ello.Serve.Web, :view

  def apple_app_id, do: Application.get_env(:ello_serve, :apple_app_id)
  def recaptcha_key, do: Application.get_env(:ello_serve, :recaptcha_key)

  def current_path(%{path: path}), do: path
  def current_path(%{conn: conn}), do: conn.request_path

  def current_url(%{url: url}), do: url
  def current_url(assigns) do
    webapp_url(current_path(assigns))
  end

  def title(%{title: title}), do: title
  def title(_), do: "Ello | The Creators Network"

  def recaptcha_action(%{path: "/join"}), do: 'join'
  def recaptcha_action(%{path: "/enter"}), do: 'login'
  def recaptcha_action(_), do: "any"

  def description(%{description: description}), do: description
  def description(_), do: "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about."

  def twitter_card(%{twitter_card: card}), do: card
  def twitter_card(_), do: "summary_large_image"

  def image(%{image: image}), do: image
  def image(_), do: "/static/images/support/ello-open-graph-image.png"
end
