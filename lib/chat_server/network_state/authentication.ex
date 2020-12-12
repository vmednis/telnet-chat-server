defmodule ChatServer.NetworkState.Authentication do
  defstruct name: "Authentication"
  def state, do: %__MODULE__{}
end

defimpl ChatServer.NetworkState, for: ChatServer.NetworkState.Authentication do
  alias ChatServer.NetworkState, as: States
  alias ChatServer.NetworkClient, as: Client
  alias ChatServer.NetworkClients, as: Clients

  def enter(_state, network_client) do
    Client.transmit(network_client, "Please enter your username: ")
  end

  def receive(_state, network_client, message) do
    username = String.trim_trailing(message)

    cond do
      valid_username?(username) ->
        cond do
          not Clients.has_username?(username) ->
            Client.transmit(
              network_client,
              "Welcome " <> IO.ANSI.red() <> username <> IO.ANSI.reset() <> "!\n"
            )

            Client.switch_state(network_client, States.Chat.state(username))

          true ->
            Client.transmit(network_client, "Looks like you are already online!")
        end

      true ->
        Client.transmit(network_client, "Invalid username!\n")
        Client.switch_state(network_client, States.Authentication.state())
    end
  end

  defp valid_username?(username) do
    username != "" && String.replace(username, ~r/\s/, "") == username
  end

  def exit(_state, _network_client) do
  end
end
