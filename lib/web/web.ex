defmodule NbaLinesServer.Web do
    @moduledoc """
    A module that keeps using definitions for controllers,
    views and so on.
    This can be used in your application as:
        use NbaLinesServer.Web, :controller
    The definitions below will be executed for every view,
    controller, etc, so keep them short and clean, focused
    on imports, uses and aliases.
    """
  
    def model do
      quote do
        use Ecto.Schema
  
        import Ecto
        import Ecto.Changeset
        import Ecto.Query, only: [from: 1, from: 2]
      end
    end

    def controller do
      quote do
        use Phoenix.Controller

        require Logger
  
        import Ecto
        import Ecto.Query, only: [from: 1, from: 2]
  
        import NbaLinesServer.Guardian.Plug, only: [current_resource: 1]
      end
    end

    def router do
      quote do
        use Phoenix.Router
      end
    end
  
    def channel do
      quote do
        use Phoenix.Channel, log_join: :debug
  
        require Logger
  
        alias NbaLinesServer.Repo
        import Ecto
        import Ecto.Query, only: [from: 1, from: 2]
        import NbaLinesServer.Gettext

        import NbaLinesServer.Guardian.Plug, only: [current_resource: 1]
  
        @doc "Handle an unauthenticated request"
        @spec join(room :: binary, params :: %{}, socket :: Phoenix.Socket.t)
          :: {:error, :authentication_required}
        def join(room, params, socket) when params == %{} do
          {:error, :authentication_required}
        end

        def verify_token(token) do
          case NbaLinesServer.Guardian.decode_and_verify(token) do
              {:ok, _claims} ->
                  {:ok, "valid_token"}
              {:error, reason} ->
                  Logger.info("invalid token #{inspect reason}")
                  {:error, "invalid_token"}
          end
        end
      end
    end
  
    @doc """
    When used, dispatch to the appropriate controller/view/etc.
    """
    defmacro __using__(which) when is_atom(which) do
      apply(__MODULE__, which, [])
    end
  end