import Config

# Configure your database
config :time_manager, TimeManager.Repo,
  username: "postgres1",
  password: "NHIFjlVgnPFmwVj0cNxeiKeejvE6waXS",
  database: "time_manager",
  hostname: "dpg-csf4as3tq21c738jdv40-a.frankfurt-postgres.render.com",
  port: 5432,
  pool_size: 10,
  ssl: true,
  ssl_opts: [
    verify: :verify_none
  ]
