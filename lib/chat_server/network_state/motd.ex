defmodule ChatServer.NetworkState.MOTD do
  defstruct name: "MOTD"
  def state, do: %__MODULE__{}
end

defimpl ChatServer.NetworkState, for: ChatServer.NetworkState.MOTD do
  alias ChatServer.NetworkState, as: States
  alias ChatServer.NetworkClient, as: Client

  def enter(_state, network_client) do
    Client.transmit(
      network_client,
      IO.ANSI.green() <>
        "Welcome to this humble chat server!\n" <> IO.ANSI.reset() <> "Press enter to join.\n"
    )
  end

  def receive(_state, network_client, _message) do
    Client.switch_state(network_client, States.Authentication.state())
  end

  def exit(_state, _network_client) do
  end
end
