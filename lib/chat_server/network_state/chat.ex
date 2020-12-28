defmodule ChatServer.NetworkState.Chat do
  defstruct name: "Chat", username: nil
  def state(username), do: %__MODULE__{username: username}
end

defimpl ChatServer.NetworkState, for: ChatServer.NetworkState.Chat do
  alias ChatServer.NetworkClient, as: Client
  alias ChatServer.NetworkClients, as: Clients

  def enter(state, network_client) do
    Clients.register(state.username, network_client)
    Clients.broadcast_except(state.username <> " has joined the chat!", state.username)
    Client.transmit(network_client, "Welcome " <> IO.ANSI.red() <> state.username <> IO.ANSI.reset() <> "!\n")
    Client.transmit(network_client, "Type /help for help\n")
  end

  def receive(state, _network_client, message) do
    msg = String.trim_trailing(message)

    unless msg == "" do
      ChatServer.Command.evaluate(state.username, String.trim_trailing(message))
    end
  end

  def exit(state, _network_client) do
    Clients.unregister(state.username)
  end
end
