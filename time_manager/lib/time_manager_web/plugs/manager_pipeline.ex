defmodule TimeManagerWeb.Plugs.ManagerPipeline do
  import Plug.Conn
  alias TimeManager.Users.User
  alias TimeManagerWeb.PlugController
  import Phoenix.Controller, only: [json: 2]

  def init(default), do: default

  def call(conn, _default) do
    # Récupère l'utilisateur actuel depuis Guardian.Plug
    current_user = Guardian.Plug.current_resource(conn)

    # Vérifie si l'utilisateur est un manager
    if current_user.is_manager == true do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied: User is not a manager"})
      |> halt()
    end
  end
end