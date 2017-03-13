defmodule Ello.Dispatch.Endpoint do
  use Phoenix.Endpoint, otp_app: :ello_dispatch

  # Call sockets directly from dispatch, plug can not handle them.
  socket "/v2/socket", Ello.V2.UserSocket
  # socket "/v3/socket", V3.UserSocket

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
  @corsheaders ["Etag", "X-Total-Count", "X-Total-Pages", "X-Total-Pages-Remaining", "Link"]
  plug CORSPlug, headers: CORSPlug.defaults[:headers] ++ @corsheaders

  plug Ello.Dispatch
end
