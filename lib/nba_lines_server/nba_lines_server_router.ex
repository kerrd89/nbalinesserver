defmodule NbaLinesServer.Router do
    # use Plug.Router
    # use Plug.Debugger
    # require Logger
    use NbaLinesServer.Web, :router
    
    pipeline :api do
        plug Plug.Logger
        # plug(:match)
        # plug(:dispatch)
        plug :accepts, "json"
    end

    pipeline :api_auth do
        # Looks in the Authorization header for the token
        plug Guardian.Plug.Pipeline, module: NbaLinesServer.Guardian,
                                 error_handler: NbaLinesServer.SessionController
    
        # Note - since we don't currently use a realm, we must set to :none
        plug Guardian.Plug.VerifyHeader, realm: :none
        plug Guardian.Plug.LoadResource
        plug NbaLinesServer.Plug.ApiAuthorizationPlug
        plug Guardian.Plug.EnsureAuthenticated
    end
  
    # get "/hello" do
    #     send_resp(conn, 200, "world")
    # end

    # # Basic example to handle POST requests wiht a JSON body
    # post "/post" do
    #     {:ok, body, conn} = read_body(conn)
        
    #     body = Poison.decode!(body)
        
    #     send_resp(conn, 201, "created: #{get_in(body, ["message"])}")
    # end
    
    
    # # "Default" route that will get called when no other route is matched
    # match _ do
    #     send_resp(conn, 404, "not found")
    # end
end
  