defmodule SetupScript do
  @base_url "http://localhost:4000/api"
  @admin_key "I/fqYUYqWzWDweQNe7Fdhid6gkSJ7S1HekNzWpkr6hJJ3pj3qsXu/dDqwtMXLQkn"

  def run do
    case create_admin() do
      {:ok, admin_token} -> create_managers_and_users(admin_token)
      :error -> IO.puts("Admin creation failed. Cannot proceed.")
    end
  end

  defp create_admin do
    payload = %{
      "user" => %{
        "email" => "admin@time_manager.com",
        "password" => "adminpass123",
        "is_admin" => true,
        "key" => @admin_key
      }
    }

    response = HTTPoison.post("#{@base_url}/user", Jason.encode!(payload), headers())

    case response do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"token" => token}} -> {:ok, token}
          _ -> :error
        end
      _ -> :error
    end
  end

  defp create_managers_and_users(admin_token) do
    # Create managers
    manager_tokens = Enum.map(1..4, fn idx ->
      create_user("manager#{idx}@time_manager.com", "managerpass#{idx}", true, admin_token)
    end)

    # Create users
    user_emails = for i <- 1..12, do: "user#{i}@time_manager.com"
    assign_users_to_managers(manager_tokens, user_emails, admin_token)
  end

  defp create_user(email, password, is_manager, admin_token) do
    payload = %{
      "user" => %{
        "email" => email,
        "password" => password,
        "is_manager" => is_manager
      }
    }

    response = HTTPoison.post("#{@base_url}/user", Jason.encode!(payload), headers(admin_token))

    case response do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"token" => token}} ->
            IO.puts("User created: #{email}")
            token
          _ ->
            IO.puts("Unexpected response format: #{body}")
            nil
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        IO.puts("Failed to create user with status #{code}: #{body}")
        nil

      {:error, reason} ->
        IO.puts("Error creating user: #{inspect(reason)}")
        nil
    end
  end

  defp assign_users_to_managers(manager_tokens, user_emails, admin_token) do
    Enum.with_index(manager_tokens, fn manager_token, idx ->
      user_set = Enum.slice(user_emails, idx * 3, 3)

      Enum.each(user_set, fn email ->
        create_user(email, "userpass#{idx}", false, admin_token) # Regular users
      end)
    end)

    IO.puts("Setup complete.")
  end

  defp headers(token \\ nil) do
    base_headers = [{"Content-Type", "application/json"}]
    case token do
      nil -> base_headers
      _ -> [{"Authorization", "Bearer #{token}"} | base_headers]
    end
  end
end

SetupScript.run()
