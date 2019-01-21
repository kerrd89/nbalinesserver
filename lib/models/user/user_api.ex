defmodule User.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.User
  
    @doc "helper method to get user by id"
    @spec get_user_by_id(user_id :: integer) :: list()
    def get_user_by_id(user_id), do: Repo.get(User, user_id)

    @doc "helper method to get user with a given email"
    @spec get_user_by_email(user_email :: String.t) :: list()
    def get_user_by_email(user_email), do: Repo.get_by(User, email: user_email)
  
    @doc "helper method to register new user"
    @spec create_user(payload :: map()) :: {:ok, User} | {:error, String.t()}
    def create_user(payload) do
        email = Map.get(payload, "email", nil)

        if not is_nil(email) and not is_nil(get_user_by_email(email)) do
            {:error, "email taken"}
        else
            user_registration_changeset = User.registration_changeset(%User{}, %{
                "deleted" => false,
                "email" => Map.get(payload, "email", nil),
                "first_name" => Map.get(payload, "first_name", nil),
                "last_name" => Map.get(payload, "last_name", nil),
                "password" => Map.get(payload, "password", nil)
            })
    
            if user_registration_changeset.valid? do
                case Repo.insert(user_registration_changeset) do
                    {:ok, %User{} = user} -> {:ok, user}
                    {:error, error_changeset} -> {:error, error_changeset.errors}
                end 
            else
                {:error, user_registration_changeset.errors}
            end
        end
    end
end