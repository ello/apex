# Note: When running in an umbrella we do not start this endpoint directly.
# Instead Ello.Dispatch.Endpoint is run.
defmodule Ello.V2.Endpoint do
  use Phoenix.Endpoint, otp_app: :ello_v2

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
    json_decoder: Poison

  plug Ello.V2.Router
end
