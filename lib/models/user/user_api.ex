defmodule User.Api do
    alias NbaLinesServer.Repo
    alias NbaLinesServer.User
  
    @doc "helper method to get all nba games for a certain date"
    @spec get_user_by_id(user_id :: integer) :: list()
    def get_user_by_id(user_id), do: Repo.get(User, user_id)
  
    @doc "helper method to register new user"
    @spec create_user(payload :: map()) :: {:ok, User} | {:error, String.t()}
    def create_user(payload) do
        user = User.registration_changeset(%User{}, %{
            "deleted" => false,
            "email" => Map.get(payload, "email", nil),
            "first_name" => Map.get(payload, "first_name", nil),
            "last_name" => Map.get(payload, "last_name", nil),
            "password" => Map.get(payload, "password", nil)
        })

        case Repo.insert(user) do
            {:ok, %User{} = user} -> {:ok, user}
            {:error, error} -> {:error, error}
        end
    end
end