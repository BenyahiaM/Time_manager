defmodule TimeManagerWeb.PlugController do
  use TimeManagerWeb, :controller
  alias TimeManager.Users.User

  def is_manager?(%User{is_manager: true}), do: true
  def is_manager?(_), do: false
end
