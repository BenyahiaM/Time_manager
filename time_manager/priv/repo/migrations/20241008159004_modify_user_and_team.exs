defmodule TimeManager.Repo.Migrations.ModifUserAndTeam do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :id_manager, references(:user, on_delete: :nothing)
    end
    alter table (:team) do
      add :id_chef, references(:user, on_delete: :delete_all)
    end
  end
end