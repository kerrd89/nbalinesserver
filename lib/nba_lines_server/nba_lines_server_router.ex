defmodule NbaLinesServer.Router do
    # use Plug.Router
    # use Plug.Debugger
    # require Logger
    use NbaLinesServer.Web, :router

    alias NbaLinesServer.SessionController
    
    pipeline :api do
        plug Plug.Logger
        # plug(:match)
        # plug(:dispatch)
        plug :accepts, "json"
    end

    pipeline :api_auth do
        # Looks in the Authorization header for the token
        plug Guardian.Plug.Pipeline, module: NbaLinesServer.Guardian,
            error_handler: SessionController
    
        # Note - since we don't currently use a realm, we must set to :none
        plug Guardian.Plug.VerifyHeader, realm: :none
        plug Guardian.Plug.LoadResource
        plug NbaLinesServer.Plug.ApiAuthorizationPlug
        plug Guardian.Plug.EnsureAuthenticated
    end
  
    post "/authenticate", SessionController, :create
    post "/login", SessionController, :login
    delete "/logout", SessionController, :logout
end
  