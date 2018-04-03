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
    Application.get_env(:ello_serve, :webapp_config)[:app_debug] == "true"
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

  def encoded_env(conn) do
    conn
    |> webapp_env()
    |> Jason.encode!
    |> URI.encode
  end

  defp webapp_env(conn) do
    env = %{
      "AUTH_CLIENT_ID"    => client_id(),
      "AUTH_DOMAIN"       => webapp_url(""),
      "APP_DEBUG"         => app_debug(conn),
      "PROMO_HOST"        => promo_host(),
      "SEGMENT_WRITE_KEY" => segment_write_key(),
    }
    case honeybadger_config() do
      {key, env_name} ->
        Map.merge(env, %{
          "HONEYBADGER_API_KEY"     => key,
          "HONEYBADGER_ENVIRONMENT" => env_name,
        })
      _ -> env
    end
  end
end
