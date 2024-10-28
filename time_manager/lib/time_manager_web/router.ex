defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TimeManagerWeb.Plugs.AuthPipeline
  end

  pipeline :admin do
    plug TimeManagerWeb.Plugs.AdminPipeline
  end

  pipeline :manager do
    plug TimeManagerWeb.Plugs.ManagerPipeline
  end

  pipeline :user do
    plug TimeManagerWeb.Plugs.UserPipeline
  end

  scope "/api/admin", TimeManagerWeb do
    pipe_through [:api, :authenticated, :admin]

    get "/user", UserController, :filter
    get "/user/:userID", UserController, :show
    post "/user", UserController, :create
    put "/user/:id", UserController, :update
    put "/user/:id/:team_id", UserController, :assign_to_team
    delete "/user/:userID", UserController, :remove

    get "/clock", ClockController, :index
    get "/clock/:id", ClockController, :show
    post "/clock", ClockController, :create
    put "/clock/:id", ClockController, :update
    delete "/clock/:id", ClockController, :remove

    get "/workingtime", WorkingTimeController, :index
    get "/workingtime/:id", WorkingTimeController, :show
    get "/workingtime?userID", WorkingTimeController, :index_by_user
    get "/workingtime/:userID/:id", WorkingTimeController, :show_by_user
    post "/workingtime", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :remove
    delete "/workingtime/:id", WorkingTimeController, :delete
    resources "/sessions", SessionController, only: [:create]

    get "/team", TeamController, :index
    get "/team/:id", TeamController, :show
    post "/team", TeamController, :create
    put "/team/:id", TeamController, :update
    delete "team/:id", TeamController, :remove
    post "/team/add_user", TeamController, :add_user_to_team
  end

  scope "/api/manager", TimeManagerWeb do
    pipe_through [:api, :authenticated, :manager]

    get "/user", UserController, :show_user_manager
    #put "/user/:id", UserController, :update
    put "/:id/:team_id", UserController, :assign_to_team

    get "/clock/:userID", ClockController, :clock_manager
    put "/clock/:userID/:id", ClockController, :update_manager

    get "/workingtime/:userID", WorkingTimeController, :workingtime_manager
    put "/workingtime/:userID/:id", WorkingTimeController, :update_manager

    get "/team", TeamController, :show_user_team
    post "/team", TeamController, :create
  end

  scope "/api/user", TimeManagerWeb do
    pipe_through [:api, :authenticated]

    get "", UserController, :show
    put "", UserController, :update #TODO : Mot de passe

    get "/clock", ClockController, :clock_user
    get "/clockStatus", ClockController, :clock_status
    post "/clock", ClockController, :create_user
    put "/clock/:id", ClockController, :update

    get "/workingtime", WorkingTimeController, :workingtime_user
    get "/workingtimeWeek", WorkingTimeController, :workingtime_user_week
    get "/workingtime/:id", WorkingTimeController, :show_user
    post "/workingtime", WorkingTimeController, :create_user

    get "/team", TeamController, :team_user
  end

  scope "/api", TimeManagerWeb do
    pipe_through :api

    resources "/sessions", SessionController, only: [:create]
    post "/createAdmin", UserController, :create_admin

    def swagger_info do
      %{
        info: %{
          version: "1.0",
          title: "Time Manager"
        },
        host: "localhost:4000",     # Définit le domaine et le port de base
        basePath: "/api",           # Définit le chemin de base de toutes les routes
        schemes: ["http"]           # Définit les protocoles supportés
      }
    end
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :time_manager, swagger_file: "swagger.json"
  end
end
