defmodule TimeManager.Repo.Migrations.RenameIsGeneralManagerToIsAdminInUser do
  use Ecto.Migration

  def change do
    rename table(:user), :is_general_manager, to: :is_admin
  end
end