defmodule TimeManagerWeb.Plugs.UserPipeline do
  import Plug.Conn
  alias TimeManager.Users.User
  alias TimeManagerWeb.PlugController
  import Phoenix.Controller, only: [json: 2]

  def init(default), do: default

  def call(conn, _default) do
    # Récupère l'utilisateur actuel depuis Guardian.Plug
    current_user = Guardian.Plug.current_resource(conn)

    user_id = conn.params["id"] || conn.params["user_id"]

    if current_user && Integer.to_string(current_user.id) == user_id do
      conn  # L'ID correspond, donc on laisse passer la requête
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied: User is not authorized to access this resource"})
      |> halt()
    end
  end
end