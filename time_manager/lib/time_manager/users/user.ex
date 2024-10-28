defmodule TimeManager.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt


  schema "user" do
    field :username, :string
    field :email, :string
    field :is_manager, :boolean, default: false
    field :is_admin, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :team, Team, foreign_key: :team_id
    belongs_to :manager, __MODULE__, foreign_key: :id_manager

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :is_manager, :is_admin, :password, :team_id, :id_manager])
    |> validate_required([:username, :email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
    |> validate_manager_exclusivity()  # Ajout de la validation personnalisée
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :is_manager, :is_admin, :team_id, :id_manager])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
  end

  def update_manager_changeset(user, attrs) do
    user
    |> cast(attrs, [:team_id])
    |> validate_manager_exclusivity()  # Validation personnalisée pour is_manager
  end

  def update_admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:is_manager, :team_id, :id_manager])
    |> validate_manager_exclusivity()  # Validation personnalisée pour is_manager
  end

  defp validate_manager_exclusivity(changeset) do
    is_manager = get_field(changeset, :is_manager)

    if is_manager do
      changeset
    else
      changeset
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end

