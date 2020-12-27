defmodule ChatServer.DB.User do
  alias ChatServer.DB.User, as: User

  use Memento.Table, 
    attributes: [:id, :username, :password_hash, :salt],
    index: [:username],
    type: :ordered_set,
    autoincrement: true
  
  def register(username, password) do
    salt = :crypto.strong_rand_bytes(16)
    password_hash = salt_hash_password(password, salt)
    user = %User{username: username, password_hash: password_hash, salt: salt}

    result = Memento.transaction(fn ->
      exists? = Memento.Query.select(__MODULE__, {:==, :username, username})
      |> Enum.empty?
      |> Kernel.not

      unless exists? do
        Memento.Query.write(user)
      else
        Memento.Transaction.abort(:already_exists)
      end
    end)

    case result do
      {:ok, _} -> :ok
      {:error, {_, reason}} -> {:error, reason}
      _ -> {:error, :unknown}
    end
  end

  def login(username, password) do
    results = Memento.transaction(fn ->
      Memento.Query.select(__MODULE__, {:==, :username, username})
    end)

    with {:ok, [user]} <- results do
      password_hash = salt_hash_password(password, user.salt)
      if user.password_hash == password_hash do
        :ok
      else
        {:error, :wrong_password}
      end
    else
      {:ok, []} -> {:error, :user_not_found}
      _ -> {:error, :unknown}
    end
  end

  defp salt_hash_password(password, salt) do
    salted_password = password <> salt
    :crypto.hash(:sha3_512, salted_password)
  end
end