# Note: When running in an umbrella we do not start this endpoint directly.
# Instead Ello.Dispatch.Endpoint is run.
defmodule Ello.Serve.Endpoint do
  use Phoenix.Endpoint, otp_app: :ello_serve

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

  plug Plug.Head

  plug Ello.Serve.Router
end
