defmodule MyApp.Repo.Migrations.AddHammerRateLimiterTable do
  use Ecto.Migration

  def up do
    create table(:hammer_rate_limits, primary_key: false) do
      add :key, :string, primary_key: true
      add :count, :integer
      add :created_at, :bigint
      add :updated_at, :bigint
    end
  end

  def down do
    drop table(:hammer_rate_limits)
  end
end
