defmodule TimeManagerWeb.SessionController do
  use TimeManagerWeb, :controller
  alias TimeManager.Repo
  alias TimeManager.Users.User
  alias TimeManagerWeb.Auth.Guardian
  import Hammer

  @max_attempts 5
  @period_in_seconds 60  # Période de 60 secondes pour limiter les tentatives

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    # Obtenir l'adresse IP de l'utilisateur
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    # Vérifier si l'IP est autorisée à faire une tentative de connexion
    case Hammer.check_rate(ip, @period_in_seconds * 1000, @max_attempts) do
      {:allow, _count} ->
        # Si l'utilisateur est autorisé à faire une tentative, on continue l'authentification
        user = Repo.get_by(User, email: email)

        if user && Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, %{})
          conn
          |> put_status(:ok)
          |> json(%{jwt: jwt})
        else
          # Si les identifiants sont invalides
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid email or password"})
        end

      {:deny, _limit} ->
        # Si l'IP a dépassé la limite de tentatives
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Too many attempts, please try again later"})
    end
  end
end
