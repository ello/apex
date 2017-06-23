defmodule Ello.Serve.Webapp.ConfigView do
  use Ello.Serve.Web, :view

  def client_id() do
    Application.get_env(:ello_serve, :webapp_oauth_client_id)
  end

  def webapp_domain() do
    "https://" <> Application.get_env(:ello_serve, :webapp_host)
  end

  def logo_mark() do
    Application.get_env(:ello_serve, :webapp_config)[:logo_mark]
  end

  def app_debug() do
    Application.get_env(:ello_serve, :webapp_config)[:app_debug]
  end

  def promo_host() do
    Application.get_env(:ello_serve, :webapp_config)[:promo_host]
  end

  def segment_write_key() do
    Application.get_env(:ello_serve, :webapp_config)[:segment_write_key]
  end
end
