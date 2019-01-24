defmodule NbaLinesServer.Guardian do
    @moduledoc """
    Module for serializing/deserializing guardian claims.
    It will serialize a user to a string identifier, as well as
    turn the string identifier back into the user model.
    """
  
    require Logger
  
    use Guardian, otp_app: :nba_lines_server
    
    def subject_for_token(%NbaLinesServer.User{} = user, _claims) do
      {:ok, to_string(user.id)}
    end
  
    def subject_for_token(_, _) do
      {:error, :reason_for_error}
    end
  
    def resource_from_claims(%{"sub" => "User:" <> user_id} = _claims) do
      case User.Api.get_user_by_id(user_id) do
        nil -> {:error, :resource_not_found}
        user -> {:ok, user}
      end
    end
  
    def resource_from_claims(_claims) do
      {:error, :reason_for_error}
    end
  
    # Events
    def after_encode_and_sign(resource, claims, token, _options) do
      with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
        {:ok, token}
      end
    end
  
    def on_verify(claims, token, _options) do
      with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
        {:ok, claims}
      end
    end
  
    def on_revoke(claims, token, _options) do
      with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
        {:ok, claims}
      end
    end
  end