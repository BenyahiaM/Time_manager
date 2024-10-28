defmodule TimeManagerWeb.TeamJSON do
  alias TimeManager.Teams.Team
  alias TimeManager.Users.User

  @doc """
  Renders a list of team.
  """
  def index(%{team: team}) do
    %{data: for(team <- team, do: data(team))}
  end

  def index_user(%{users: users, team: team, chef: chef}) do
    %{
      team: %{
        id: team.id,
        name: team.name
      },
      users: for(user <- users, do: data_user(user)),
      chef: %{
        id: chef.id,
        username: chef.username
      }
    }
  end


  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  def show_user(%{user: user}) do
    %{data_user: data_user(user)}
  end

  #Pb lorsqu'on affiche les data, si user vide pb voir ça
  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      chef: team.id_chef
    }
  end

  defp data_user(%User{} = user) do
    %{
      id: user.id,
      name: user.username
    }
  end
end
