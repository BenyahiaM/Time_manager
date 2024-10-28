defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  alias TimeManager.Clocks
  alias TimeManager.Clocks.Clock
  alias TimeManager.Users

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    case Clocks.list_clock() do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found"})

        clocks ->
          conn
          |> put_status(:ok)
          |> render(:index, clock: clocks)
    end
  end

  def clock_user(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    case Clocks.get_clock_user(current_user.id) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found for user : #{current_user.id}"})

      clocks ->
        conn
        |> put_status(:ok)
        |> render(:index, clock: clocks)
    end
  end

  def clock_manager(conn, %{"UserID" => userID}) do
    case Clocks.get_clock_user(userID) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found for user : #{userID}"})

      clocks ->
        conn
        |> put_status(:ok)
        |> render(:index, clock: clocks)
    end
  end

  def clock_status(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    case Clocks.get_latest_clock_user(current_user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found for user : #{current_user.id}"})

      clock ->
        conn
        |> put_status(:ok)
        |> json(%{status: clock.status})
    end
  end

  def create(conn, %{"clock" => clock_params}) do
    if Map.has_key?(clock_params, "time") and Map.has_key?(clock_params, "status") and Map.has_key?(clock_params, "user_id") do
      with {:ok, %Clock{} = clock} <- Clocks.create_clock(clock_params) do
        conn
        |> put_status(:created)
        |> render(:show, clock: clock)
        else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: time, status, user_id"})
    end
  end

  def create_user(conn, %{"clock" => clock_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    if Map.has_key?(clock_params, "time") and Map.has_key?(clock_params, "status") do

      clock_params_with_user_id = Map.put(clock_params, "user_id", current_user.id)
      with {:ok, %Clock{} = clock} <- Clocks.create_clock(clock_params_with_user_id) do
        conn
        |> put_status(:created)
        |> render(:show, clock: clock)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: time, status, user_id"})
    end
  end

  def show(conn, %{}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Clocks.get_clock_user(current_user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock not found with ID #{current_user.id}"})

        clock ->
          render(conn, :show, clock: clock)
    end
  end

  def update(conn, %{"id" => id, "clock" => clock_params}) do
    case Clocks.get_clock(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock  not found with ID #{id}"})

      clock ->
        with {:ok, %Clock{} = clock} <- Clocks.update_clock(clock, clock_params) do
          conn
          |> put_status(:ok)
          |> render(:show, clock: clock)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  def update_manager(conn, %{"userID" => user_id, "id" => clock_id, "clock" => clock_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Users.get_user(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User with ID #{user_id} not found"})

      user ->
        # Vérification que l'utilisateur appartient à la même équipe que le current_user (manager)
        if user.id_manager == current_user.id do
          # Récupération de la clock à mettre à jour
          case Clocks.get_clock(clock_id) do
            nil ->
              conn
              |> put_status(:not_found)
              |> json(%{error: "Clock with ID #{clock_id} not found"})

            clock ->
              # Mise à jour de la clock
              case Clocks.update_clock(clock, clock_params) do
                {:ok, updated_clock} ->
                  conn
                  |> put_status(:ok)
                  |> render(:show, clock: updated_clock)

                {:error, changeset} ->
                  conn
                  |> put_status(:unprocessable_entity)
                  |> json(%{errors: translate_errors(changeset)})
              end
          end
        else
          # Si l'utilisateur n'est pas dans la même équipe que le manager
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Access denied: You are not authorized to update this user's clock"})
        end
    end
  end

  def remove(conn, %{"id" => id}) do
    case Clocks.get_clock(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock  not found with ID #{id}"})

      clock ->
        with {:ok, %Clock{}} <- Clocks.delete_clock(clock) do
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "Clock supprimé")
        else
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete clock"})
        end
    end
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
      Clock: swagger_schema do
        title "Clock"
        description "Un enregistrement d'horloge pour un utilisateur (heure d'entrée/sortie)"
        properties do
          id :integer, "Identifiant de l'enregistrement", required: true
          status :boolean, "Indique si l'utilisateur est actuellement clocké", required: true
          time :string, "Heure à laquelle l'utilisateur s'est clocké", format: "date-time", required: true
          user_id :integer, "Identifiant de l'utilisateur associé", required: true
        end
        example %{
          id: 1,
          status: true,
          time: "2024-10-11T08:00:00Z",
          user_id: 1
        }
      end
    }
  end

  ### USER
  swagger_path :clock_user do
    get "/user/clock"
    summary "Lister tous les enregistrements d'horloge d'un utilisateur"
    description "Retourne une liste de tous les enregistrements d'horloge pour un utilisateur."
    response 200, "Succès", Schema.array(:Clock)
  end

  swagger_path :clock_status do
    get "/user/clockStatus"
    summary "Retourne le status de la dernier clock de l'utilisateur"
    description "Retourne le status de la dernier clock de l'utilisateur"
    response 200, "Succès", Schema.array(:Clock)
  end

  swagger_path :create_user do
    post "/user/clock"
    summary "Créer un nouvel enregistrement d'horloge"
    parameters do
      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à créer", required: true)
    end
    response 201, "Enregistrement créé", Schema.ref(:Clock)
  end

  swagger_path :update do
    put "/user/clock/{id}"
    summary "Mettre à jour un enregistrement d'horloge par ID"
    parameters do
      id(:path, :integer, "ID de l'enregistrement", required: true)
      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à mettre à jour", required: true)
    end
    response 200, "Enregistrement mis à jour", Schema.ref(:Clock)
    response 404, "Enregistrement non trouvé"
  end

  ### MANAGER

  swagger_path :clock_manager do
    get "/manager/clock/{userID}"
    summary "Lister tous les enregistrements d'horloge d'un utilisateur d'un manager"
    description "Retourne une liste de tous les enregistrements d'horloge pour l'utilisateur d'un manager choisi."
    response 200, "Succès", Schema.array(:Clock)
  end

  swagger_path :update do
    put "/manager/clock/{userID}/{id}"
    summary "Mettre à jour un enregistrement d'horloge par un ID pour un utilisateur d'un manager"
    parameters do
      id(:path, :integer, "ID de l'enregistrement", required: true)
      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à mettre à jour", required: true)
    end
    response 200, "Enregistrement mis à jour", Schema.ref(:Clock)
    response 404, "Enregistrement non trouvé"
  end

  ### -------------------------------------------------------------------------




  # Swagger path to list all clock entries
#  swagger_path :index do
#    get "/clock"
#    summary "Lister tous les enregistrements d'horloge"
#    description "Retourne une liste de tous les enregistrements d'horloge pour les utilisateurs."
#    response 200, "Succès", Schema.array(:Clock)
#  end
#
#  # Swagger path to show a clock entry by ID
#  swagger_path :show do
#    get "/clock/{id}"
#    summary "Afficher un enregistrement d'horloge par ID"
#    parameters do
#      id(:path, :integer, "ID de l'enregistrement", required: true)
#    end
#    response 200, "Succès", Schema.ref(:Clock)
#    response 404, "Enregistrement non trouvé"
#  end
#
#  # Swagger path to create a new clock entry
#  swagger_path :create do
#    post "/clock"
#    summary "Créer un nouvel enregistrement d'horloge"
#    parameters do
#      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à créer", required: true)
#    end
#    response 201, "Enregistrement créé", Schema.ref(:Clock)
#  end
#
#  # Swagger path to update an existing clock entry
#  swagger_path :update do
#    put "/clock/{id}"
#    summary "Mettre à jour un enregistrement d'horloge par ID"
#    parameters do
#      id(:path, :integer, "ID de l'enregistrement", required: true)
#      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à mettre à jour", required: true)
#    end
#    response 200, "Enregistrement mis à jour", Schema.ref(:Clock)
#    response 404, "Enregistrement non trouvé"
#  end
#
#  # Swagger path to delete a clock entry
#  swagger_path :remove do
#    delete "/clock/{id}"
#    summary "Supprimer un enregistrement d'horloge par ID"
#    parameters do
#      id(:path, :integer, "ID de l'enregistrement", required: true)
#    end
#    response 204, "Enregistrement supprimé"
#    response 404, "Enregistrement non trouvé"
#  end
end
