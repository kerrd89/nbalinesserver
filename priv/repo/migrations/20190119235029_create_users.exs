defmodule Cart.Repo.Migrations.CreateUsers do
    use Ecto.Migration
  
    def change do
      create table(:users) do
        add :first_name, :string
        add :last_name, :string
        add :email, :string
        add :password_hash, :string
        add :deleted, :boolean
  
        timestamps()
      end
    end
  end