defmodule TimeManager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias TimeManager.Users.User

  schema "team" do
    field :name, :string
    has_many :user, User
    belongs_to :chef, User, foreign_key: :id_chef

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :id_chef])
    |> validate_required([:name, :id_chef])
  end


end
