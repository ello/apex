defmodule Ello.Serve.Webapp.ConfigView do
  use Ello.Serve.Web, :view

  def client_id() do
    Application.get_env(:ello_serve, :webapp_oauth_client_id)
  end

  def logo_mark() do
    Application.get_env(:ello_serve, :webapp_config)[:logo_mark]
  end

  def app_debug(%{assigns: %{debug: true}}),  do: true
  def app_debug(%{assigns: %{debug: false}}), do: false
  def app_debug(_) do
    Application.get_env(:ello_serve, :webapp_config)[:app_debug]
  end

  def promo_host() do
    Application.get_env(:ello_serve, :webapp_config)[:promo_host]
  end

  def segment_write_key() do
    Application.get_env(:ello_serve, :webapp_config)[:segment_write_key]
  end

  def honeybadger_config() do
    case Application.get_env(:ello_serve, :webapp_config)[:honeybadger_api_key] do
      nil -> nil
      key ->
        env = Application.get_env(:ello_serve, :webapp_config)[:honeybadger_environment]
        {key, env}
    end
  end
end
