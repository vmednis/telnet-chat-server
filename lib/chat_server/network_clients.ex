defmodule ChatServer.NetworkClients do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register(username, network_client) do
    Agent.update(__MODULE__, &Map.put_new(&1, username, network_client))
  end

  def unregister(username) do
    Agent.update(__MODULE__, fn clients -> 
      {_, clients} = Map.pop(clients, username)
      clients
    end)
  end

  def broadcast(message), do: broadcast_except(message, nil)

  def broadcast_except(message, except_user) do
    Agent.get(__MODULE__, & &1)
    |> Enum.each(fn {username, network_client} ->
      unless username == except_user do
        ChatServer.NetworkClient.transmit(network_client, message <> "\n")
      end
    end)
  end

  def transmit(username, message) do
    Agent.get(__MODULE__, & &1)
    |> Map.get(username)
    |> ChatServer.NetworkClient.transmit(message <> "\n")
  end

  def registered_usernames() do
    Agent.get(__MODULE__, & &1)
    |> Enum.map(fn {username, _client} -> username end)
  end

  def retrieve(username) do
    Agent.get(__MODULE__, & &1)
    |> Map.get(username)
  end

  def has_username?(username) do
    Agent.get(__MODULE__, & &1)
    |> Map.has_key?(username)
  end
end
