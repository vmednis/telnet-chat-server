defmodule ChatServer do
  use Application

  @impl true
  def start(_type, _args) do
    port = 6789

    children = [
      {Task.Supervisor, name: ChatServer.ReceiverSupervisor},
      Supervisor.child_spec({Task, fn -> ChatServer.NetworkManager.accept(port) end},
        restart: :permanent
      ),
      ChatServer.NetworkClients
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
