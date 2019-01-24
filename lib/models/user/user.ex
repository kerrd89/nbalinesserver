defmodule NbaLinesServer.User do
    @moduledoc """
    The User module provides a schema interface to query and retrieve data
    about users, as well as providing methods to change a users password
    and form error messages to pass back about user operations
    (password/email change invalid, for example).
    """
    
    use NbaLinesServer.Web, :model

    alias Comeonin.Bcrypt
  
    @derive {Poison.Encoder, only: [:email, :id, :first_name, :last_name]}
  
    schema "users" do
      field :first_name, :string
      field :last_name, :string
      field :email, :string
      field :password, :string, virtual: true
      field :password_hash, :string
      field :deleted, :boolean
  
      timestamps()
    end
  
    @required_fields [:first_name, :last_name, :email]
    @optional_fields [:deleted, :password]
  
    @doc """
    Creates a changeset based on the `model` and `params`.
    If no params are provided, an invalid changeset is returned
    with no validation performed.
    """
    def changeset(model, params \\ :empty) do
      model
      |> cast(params, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)
    end
  
    def registration_changeset(model, params) do
      model
      |> changeset(params)
      |> cast(params, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)
      |> unique_constraint(:email)
      |> validate_length(:password, min: 6, max: 100)
      |> put_pass_hash()
    end
  
    def password_changeset(model, params) do
      model
      |> changeset(params)
      |> cast(params, [:password])
      |> validate_required([:password])
      |> validate_length(:password, min: 6, max: 100)
      |> put_pass_hash()
    end
  
    def delete_changeset(model, params) do
      model
      |> cast(params, [:deleted])
      |> validate_required([:deleted])
    end
  
    defp put_pass_hash(passed_changeset) do
      case passed_changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          change(passed_changeset, password_hash: Bcrypt.hashpwsalt(pass))
        _ ->
          passed_changeset
      end
    end
  end