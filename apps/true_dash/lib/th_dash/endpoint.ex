# Note: When running in an umbrella we do not start this endpoint directly.
# Instead TH.TrueDash.Endpoint is run.
defmodule TH.TrueDash.Endpoint do
  use Phoenix.Endpoint, otp_app: :true_dash

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

  plug TH.TrueDash.Router
end
