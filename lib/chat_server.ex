defmodule ChatServer do
  use Application

  @impl true
  def start(_type, _args) do
    port = 6789

    init_db()
    :mnesia.wait_for_tables([ChatServer.DB.User], :infinity)

    children = [
      {Task.Supervisor, name: ChatServer.ReceiverSupervisor},
      Supervisor.child_spec({Task, fn -> ChatServer.NetworkManager.accept(port) end},
        restart: :permanent
      ),
      ChatServer.NetworkClients
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp init_db() do
    nodes = [ node() ]

    Memento.stop()
    Memento.Schema.create(nodes)
    Memento.start()

    Memento.Table.create(ChatServer.DB.User, disc_copies: nodes)
  end
end
