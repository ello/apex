# Note: When running in an umbrella we do not start this endpoint directly.
# Instead TH.Dash.Endpoint is run.
defmodule TH.Dash.Endpoint do
  use Phoenix.Endpoint, otp_app: :th_dash

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug TH.Dash.Router
end
