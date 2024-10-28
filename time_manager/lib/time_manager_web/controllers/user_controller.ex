defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  import Ecto.Query
  import Plug.Conn
  alias TimeManager.Users
  alias TimeManager.Users.User
  alias TimeManagerWeb.UserJSON
  alias TimeManager.Teams.Team
  alias TimeManager.Repo

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    case Users.list_user() do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No users found"})

      users ->
        conn
        |> put_status(:ok)
        |> render(:index, user: users)
    end
  end

  def team_user(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    # Vérifie si l'utilisateur a une équipe assignée
    if is_nil(current_user.team_id) do
      conn
      |> put_status(:bad_request)  # Statut approprié pour une demande incorrecte
      |> json(%{error: "User doesn't have a team"})
    else
      case Users.get_user_team(current_user.team_id) do
        [] ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "No user found with ID of the team #{current_user.team_id}"})

        users ->
          conn
          |> put_status(:ok)
          |> render(:index, user: users)  # Rends la vue de l'équipe
      end
    end
  end

  def create(conn, %{"user" => user_params}) do
    if Map.has_key?(user_params, "email") and Map.has_key?(user_params, "username") and Map.has_key?(user_params, "password") do
      with {:ok, %User{} = user} <- Users.create_user(user_params) do
        conn
        |> put_status(:created)
        |> render(:show, user: user)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: email, username and password"})
    end
  end
  def create_admin(conn, %{"user" => user_params}) do
    admin_unique_key = System.get_env("admin_unique")
    is_admin = user_params["admin"] == admin_unique_key
    user_params = user_params |> Map.drop(["admin"]) |> Map.put("is_admin", is_admin)

    if required_fields_present?(user_params) do
      case Users.create_user(user_params) do
        {:ok, %User{} = user} ->
          conn
          |> put_status(:created)
          |> render(:show, user: user)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: email, username, and password"})
    end
  end

  defp admin_check(admin_key, admin_unique_key) do
    admin_key == admin_unique_key
  end

  defp required_fields_present?(params) do
    Map.has_key?(params, "email") and Map.has_key?(params, "username") and Map.has_key?(params, "password")
  end


  def show(conn, %{}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Users.get_user(current_user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found with ID #{current_user.id}"})

      user ->
        render(conn, :show, user: user)
    end
  end

  def show_manager(conn, %{}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Users.get_user_manager(current_user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found with ID of manager #{current_user.id}"})

      users ->
        render(conn, :index, user: users)
    end
  end

  def update(conn, %{"user" => user_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Users.get_user(current_user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found with ID #{current_user.id}"})

      user ->
        with {:ok, %User{} = updated_user} <- Users.update_user(user, user_params) do
          conn
          |> put_status(:ok)
          |> render(:show, user: updated_user)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  def assign_to_team(conn, %{"id" => user_id, "team_id" => team_id}) do
    # Récupérer l'utilisateur et l'équipe par ID
    user = Repo.get(User, user_id)
    team = Repo.get(Team, team_id)

    # Vérifier si l'utilisateur et l'équipe existent
    cond do
      is_nil(user) ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      is_nil(team) ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      true ->
        # Mettre à jour l'utilisateur avec la nouvelle équipe
        changeset = User.update_changeset(user, %{team_id: team.id})

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(UserJSON.show_user(%{user: updated_user}))

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: changeset.errors})
        end
    end
  end

  def remove(conn, %{"userID" => id}) do
    case Users.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found with ID #{id}"})

      user ->
        with {:ok, %User{}} <- Users.delete_user(user) do
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "Utilisateur supprimé")
        else
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete user"})
        end
    end
  end

  def filter(conn, %{"email" => email, "username" => username, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.email == ^email and u.username == ^username and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"email" => email, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.email == ^email and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"username" => username, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.username == ^username and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"team_id" => team_id}) do
    users =
      User
      |> where([u], u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"email" => email}) do
    users =
      User
      |> where([u], u.email == ^email)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"username" => username}) do
    users =
      User
      |> where([u], u.username == ^username)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, _params) do
    users = Repo.all(User)

    render_users(conn, users)
  end

  defp render_users(conn, user) do
    conn
    |> put_status(:ok)
    |> json(UserJSON.index(%{user: user}))
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def swagger_definitions do
    %{
      User: swagger_schema do
        title "User"
        description "A user of the application"
        properties do
          id :integer, "Identifiant", required: true
          username :string, "Pseudonyme", required: true
          email :string, "Adresse mail", required: true
          password :string, "Password", required: true
          is_manager :boolean, "Est un manager"
          is_admin :boolean, "Est un admin"
          team_id :integer, "Identifiant de son équipe"
        end
      end,
    }
  end

  ### USER

  swagger_path :show do
    get "/user"
    summary "Afficher un utilisateur par ID"
    parameters do
      userID(:path, :integer, "ID de l'utilisateur", required: true)
    end
    response 200, "Utilisateur trouvé", Schema.ref(:User)
    response 404, "Utilisateur non trouvé"
  end

  swagger_path :update do
    put "/user"
    summary "Mettre à jour un utilisateur par ID"
    parameters do
      id(:path, :integer, "ID de l'utilisateur", required: true)
      user(:body, Schema.ref(:User), "Détails de l'utilisateur à mettre à jour", required: true)
    end
    response 200, "Utilisateur mis à jour", Schema.ref(:User)
    response 404, "Utilisateur non trouvé"
  end


  ### MANAGER

  swagger_path :show_user_manager do
    get "/manager/user"
    summary "Lister tous les utilisateurs d'un manager"
    description "Retourne une liste de tous les utilisateurs d'un manager."
    response 200, "Succès", Schema.ref(:User)
  end

  swagger_path :assign_to_team do
    put "/manager/{id}/{team_id}"
    summary "Assigner un utilisateur à une équipe"
    parameters do
      id(:path, :integer, "ID de l'utilisateur", required: true)
      team_id(:path, :integer, "ID de l'équipe", required: true)
    end
    response 200, "Utilisateur assigné à l'équipe"
    response 404, "Utilisateur ou équipe non trouvés"
  end

  ### --------------------------------------------------------------



#  swagger_path :index do
#    get "/user"
#    summary "Lister tous les utilisateurs"
#    description "Retourne une liste de tous les utilisateurs."
#    response 200, "Succès", Schema.ref(:User)
#  end
#
#  swagger_path :create do
#    post "/user"
#    summary "Créer un nouvel utilisateur"
#    parameters do
#      user(:body, Schema.ref(:User), "Détails de l'utilisateur à créer", required: true)
#    end
#    response 201, "Utilisateur créé", Schema.ref(:User)
#  end
#
#  swagger_path :remove do
#    delete "/user/{userID}"
#    summary "Supprimer un utilisateur par ID"
#    parameters do
#      id(:path, :integer, "ID de l'utilisateur", required: true)
#    end
#    response 204, "Utilisateur supprimé"
#    response 404, "Utilisateur non trouvé"
#  end
#
#  swagger_path :filter do
#    get "/user"
#    summary "Filtrer les utilisateurs"
#    parameters do
#      email(:query, :string, "Email de l'utilisateur")
#      username(:query, :string, "Nom d'utilisateur")
#      team_id(:query, :integer, "ID de l'équipe")
#    end
#    response 200, "Liste des utilisateurs filtrés", Schema.ref(:User)
#  end
end
