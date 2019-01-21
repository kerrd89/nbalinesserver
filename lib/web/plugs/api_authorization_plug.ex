defmodule NbaLinesServer.Plug.ApiAuthorizationPlug do
    import Plug.Conn
  
    import Phoenix.Controller
    import Guardian.Plug, only: [current_resource: 1]
    
    def init(opts) do
      opts
    end
  
    def call(conn, []) do
      # Who is this person (get resource)
      user = current_resource(conn)
  
      if not is_nil(user) do
        conn
      else
        conn
        |> json(%{
          "success" => false,
          "data" => "user DNE"
        })
        |> halt()
      end
    end
  end