defmodule TimeManagerWeb.WorkingTimeController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  import Ecto.Query
  alias TimeManager.WorkingTimes
  alias TimeManager.WorkingTimes.WorkingTime
  alias TimeManager.Repo
  alias TimeManagerWeb.WorkingTimeJSON

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    case WorkingTimes.list_workingtime() do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No working times found"})

      workingtime ->
        conn
        |> put_status(:ok)
        |> render(:index, workingtime: workingtime)
    end
  end

  def workingtime_user(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    case WorkingTimes.get_workingtime_user(current_user.id) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No working times found for user #{current_user.id}"})

      workingtime ->
        conn
        |> put_status(:ok)
        |> render(:index, workingtime: workingtime)
    end
  end

  def workingtime_user_week(conn, %{"start" => start_date, "end" => end_date}) do
    current_user = Guardian.Plug.current_resource(conn)
    case WorkingTimes.get_working_times_in_range(current_user.id, start_date, end_date) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No working times found for user #{current_user.id} with the range provided"})

      workingtime ->
        conn
        |> put_status(:ok)
        |> render(:index, workingtime: workingtime)
    end
  end

  def workingtime_manager_week(conn, %{"userID" => userID, "start" => start_date, "end" => end_date}) do
    case WorkingTimes.get_working_times_in_range(userID, start_date, end_date) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No working times found for user #{userID} with the range provided"})

      workingtime ->
        conn
        |> put_status(:ok)
        |> render(:index, workingtime: workingtime)
    end
  end

  def create_user(conn, %{"working_time" => working_time_params}) do
    # Récupération de l'utilisateur courant
    current_user = Guardian.Plug.current_resource(conn)

    # Vérification des champs requis (ajuster selon tes besoins)
    if Map.has_key?(working_time_params, "start") and Map.has_key?(working_time_params, "end") do
      # Ajout du user_id aux paramètres
      working_time_params_with_user_id = Map.put(working_time_params, "user_id", current_user.id)

      with {:ok, %WorkingTime{} = working_time} <- WorkingTimes.create_working_time(working_time_params_with_user_id) do
        conn
        |> put_status(:created)
        |> render(:show, working_time: working_time)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: start_time, end_time and user_id"})
    end
  end

  def create(conn, %{"working_time" => working_time_params}) do
    # Vérification des champs requis (ajuster selon tes besoins)
    if Map.has_key?(working_time_params, "start") and Map.has_key?(working_time_params, "end") and Map.has_key?(working_time_params, "user_id") do
      with {:ok, %WorkingTime{} = working_time} <- WorkingTimes.create_working_time(working_time_params) do
        conn
        |> put_status(:created)
        |> render(:show, working_time: working_time)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: start_time, end_time and user_id"})
    end
  end

  def create_user(conn, %{"working_time" => working_time_params}) do
    # Vérification des champs requis (ajuster selon tes besoins)
    if Map.has_key?(working_time_params, "start") and Map.has_key?(working_time_params, "end") do
      with {:ok, %WorkingTime{} = working_time} <- WorkingTimes.create_working_time(working_time_params) do
        conn
        |> put_status(:created)
        |> render(:show, working_time: working_time)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: start_time, end_time and user_id"})
    end
  end

  def show(conn, %{"id" => id}) do
    case WorkingTimes.get_working_time(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found with ID #{id}"})

      working_time ->
        conn
        |> put_status(:ok)
        |> render(:show, working_time: working_time)
    end
  end

  def show_user(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case WorkingTimes.get_workingtime_user_and_id(current_user.id, id) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found with ID #{id}"})

      workingtime ->
        conn
        |> put_status(:ok)
        |> render(:index, workingtime: workingtime)
    end
  end


  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    case WorkingTimes.get_working_time(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found with ID #{id}"})

      working_time ->
        with {:ok, %WorkingTime{} = updated_working_time} <- WorkingTimes.update_working_time(working_time, working_time_params) do
          conn
          |> put_status(:ok)
          |> render(:show, working_time: updated_working_time)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  def update_manager(conn, %{"userID" => user_id, "id" => workingtime_id, "workingtime" => workingtime_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Users.get_user(user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User with ID #{user_id} not found"})

      user ->
        # Vérification que l'utilisateur appartient à la même équipe que le current_user (manager)
        if user.id_manager == current_user.id do
          case WorkingTimes.get_working_time(workingtime_id) do
            nil ->
              conn
              |> put_status(:not_found)
              |> json(%{error: "Clock with ID #{workingtime_id} not found"})

            workingtime ->
              case WorkingTimes.update_working_time(workingtime, workingtime_params) do
                {:ok, updated_workingtime} ->
                  conn
                  |> put_status(:ok)
                  |> render(:show, workingtime: updated_workingtime)

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
          |> json(%{error: "Access denied: You are not authorized to update this user's workingtime"})
        end
    end
  end

  def remove(conn, %{"id" => id}) do
    case WorkingTimes.get_working_time(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found with ID #{id}"})

      working_time ->
        with {:ok, %WorkingTime{}} <- WorkingTimes.delete_working_time(working_time) do
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "")
        else
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete working time"})
        end
    end
  end

  # Nouvelle action pour gérer la requête GET /workingtime/:userID/:id
  def show_by_user(conn, %{"userID" => user_id, "id" => workingtime_id}) do
    # Recherche du workingtime pour l'utilisateur donné
    case Repo.get_by(WorkingTime, user_id: user_id, id: workingtime_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      working_time ->
        conn
        |> put_status(:ok)
        |> json(WorkingTimeJSON.show(%{working_time: working_time}))  # Utilise WorkingTimeJSON pour encoder la réponse
    end
  end

  def index_by_user(conn, %{"userID" => user_id}) do
    start_time = conn.query_params["start"]
    end_time = conn.query_params["end"]

    working_times =
      WorkingTime
      |> where(user_id: ^user_id)
      |> filter_by_time_range(start_time, end_time)
      |> Repo.all()

    conn
    |> put_status(:ok)
    |> json(WorkingTimeJSON.index(%{workingtime: working_times}))
  end

  defp filter_by_time_range(query, nil, nil), do: query

  defp filter_by_time_range(query, start_time, nil) do
    case DateTime.from_iso8601(start_time) do
      {:ok, start_datetime, _} ->
        from(w in query, where: w.start >= ^start_datetime)

      {:error, _} ->
        query  # ou tu pourrais lever une erreur si la conversion échoue
    end
  end

  defp filter_by_time_range(query, nil, end_time) do
    case DateTime.from_iso8601(end_time) do
      {:ok, end_datetime, _} ->
        from(w in query, where: w.end <= ^end_datetime)

      {:error, _} ->
        query  # ou lever une erreur
    end
  end

  defp filter_by_time_range(query, start_time, end_time) do
    case {DateTime.from_iso8601(start_time), DateTime.from_iso8601(end_time)} do
      {{:ok, start_datetime, _}, {:ok, end_datetime, _}} ->
        from(w in query,
          where: w.start >= ^start_datetime and w.end <= ^end_datetime
        )

      _ ->
        query  # ou lever une erreur si la conversion échoue
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  # Swagger schema definition for WorkingTime
  def swagger_definitions do
    %{
      WorkingTime: swagger_schema do
        title "WorkingTime"
        description "Un enregistrement des heures de travail d'un utilisateur"
        properties do
          id :integer, "Identifiant du temps de travail", required: true
          start_time :string, "Heure de début du travail", format: "date-time", required: true
          end_time :string, "Heure de fin du travail", format: "date-time", required: true
          user_id :integer, "Identifiant de l'utilisateur associé", required: true
        end
      end
    }
  end

  ### USER
  swagger_path :workingtime_user do
    get "/user/workingtime"
    summary "Lister tous les temps de travail d'un utilisateur"
    description "Retourne une liste de tous les temps de travail."
    response 200, "Succès", Schema.array(:WorkingTime)
  end

  swagger_path :workingtime_user_week do
    get "/user/workingtime"
    summary "Lister les temps de travail dans un interval de temps défini d'un utilisateur"
    description "Retourne une liste de tous les temps de travail."
    response 200, "Succès", Schema.array(:WorkingTime)
  end

  swagger_path :show_user do
    get "/user/workingtime/:id"
    summary "Afficher un temps de travail avec son ID appartenant à l'utilisateur"
    description "Retourne une liste de tous les temps de travail."
    response 200, "Succès", Schema.array(:WorkingTime)
  end

  swagger_path :create_user do
    post "/workingtime"
    summary "Créer un nouveau temps de travail"
    parameters do
      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à créer", required: true)
    end
    response 201, "Temps de travail créé", Schema.ref(:WorkingTime)
  end

  ### MANAGER

  swagger_path :workingtime_manager do
    get "/manager/workingtime/{userID}"
    summary "Lister tous les temps de travail de l'utilisateur d'un manager"
    description "Retourne une liste de tous les temps de  de l'utilisateur d'un manager."
    response 200, "Succès", Schema.array(:WorkingTime)
  end

  swagger_path :update do
    put "/manager/workingtime/{userID}/{id}"
    summary "Mettre à jour un temps de travail par ID pour un utilisateur d'un manager"
    parameters do
      id(:path, :integer, "ID du temps de travail", required: true)
      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à mettre à jour", required: true)
    end
    response 200, "Temps de travail mis à jour", Schema.ref(:WorkingTime)
    response 404, "Temps de travail non trouvé"
  end

  ### --------------------------------------------------------------



  # Swagger path to list all working times
#  swagger_path :index do
#    get "/workingtime"
#    summary "Lister tous les temps de travail"
#    description "Retourne une liste de tous les temps de travail."
#    response 200, "Succès", Schema.array(:WorkingTime)
#  end
#
#  # Swagger path to list working times by user
#  swagger_path :index_by_user do
#    get "/workingtime/{userID}"
#    summary "Lister les temps de travail d'un utilisateur"
#    parameters do
#      userID(:path, :integer, "ID de l'utilisateur", required: true)
#    end
#    response 200, "Succès", Schema.array(:WorkingTime)
#    response 404, "Utilisateur non trouvé"
#  end
#
#  # Swagger path to show a specific working time for a user
#  swagger_path :show_by_user do
#    get "/workingtime/{userID}/{id}"
#    summary "Afficher un temps de travail par ID pour un utilisateur"
#    parameters do
#      userID(:path, :integer, "ID de l'utilisateur", required: true)
#      id(:path, :integer, "ID du temps de travail", required: true)
#    end
#    response 200, "Succès", Schema.ref(:WorkingTime)
#    response 404, "Temps de travail ou utilisateur non trouvé"
#  end
#
#  # Swagger path to create a new working time
#  swagger_path :create do
#    post "/workingtime"
#    summary "Créer un nouveau temps de travail"
#    parameters do
#      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à créer", required: true)
#    end
#    response 201, "Temps de travail créé", Schema.ref(:WorkingTime)
#  end
#
#  # Swagger path to update an existing working time
#  swagger_path :update do
#    put "/workingtime/{id}"
#    summary "Mettre à jour un temps de travail par ID"
#    parameters do
#      id(:path, :integer, "ID du temps de travail", required: true)
#      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à mettre à jour", required: true)
#    end
#    response 200, "Temps de travail mis à jour", Schema.ref(:WorkingTime)
#    response 404, "Temps de travail non trouvé"
#  end
#
#  # Swagger path to delete a working time
#  swagger_path :remove do
#    delete "/workingtime/{id}"
#    summary "Supprimer un temps de travail par ID"
#    parameters do
#      id(:path, :integer, "ID du temps de travail", required: true)
#    end
#    response 204, "Temps de travail supprimé"
#    response 404, "Temps de travail non trouvé"
#  end
end
