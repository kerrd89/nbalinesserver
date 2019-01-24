defmodule NbaLinesServer.Router do
    # use Plug.Router
    use Plug.Debugger
    require Logger
    use NbaLinesServer.Web, :router
    
    pipeline :api do
        plug Plug.Logger
        # plug :accepts, "json"
    end

    pipeline :api_auth do
        # Looks in the Authorization header for the token
        plug Guardian.Plug.Pipeline, module: NbaLinesServer.Guardian,
            error_handler: NbaLinesServer.SessionController
    
        # Note - since we don't currently use a realm, we must set to :none
        plug Guardian.Plug.VerifyHeader, realm: :none
        plug NbaLinesServer.Plug.ApiAuthorizationPlug
        plug Guardian.Plug.EnsureAuthenticated
    end

    scope "/" do
        pipe_through [:api]
        post "/login", NbaLinesServer.SessionController, :login
        delete "/logout", NbaLinesServer.SessionController, :logout
    end
end
  