defmodule NbaLinesServer.Endpoint do
    use Phoenix.Endpoint, otp_app: :nba_lines_server
  
    socket "/socket", NbaLinesServer.UserSocket
  
    plug Plug.RequestId
  
    plug Plug.Parsers,
      json_decoder: Poison,
      length: 100_000_000,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"]
  
    plug Plug.MethodOverride
    plug Plug.Head
  
    plug Plug.Session,
      store: :cookie,
      key: "_NbaLinesServer_key",
      signing_salt: "4Q1cajEv"
  
    plug CORSPlug
    plug NbaLinesServer.Router
end