defmodule ChatServer.NetworkState.Authentication do
  defstruct name: "Authentication", substate: nil, data: nil
  def state, do: %__MODULE__{}
  def state(substate, data), do: %__MODULE__{substate: substate, data: data}
end

defimpl ChatServer.NetworkState, for: ChatServer.NetworkState.Authentication do
  alias ChatServer.NetworkState, as: States
  alias ChatServer.NetworkClient, as: Client
  alias ChatServer.NetworkClients, as: Clients

  def enter(%States.Authentication{substate: nil}, network_client), do: switch_substate(network_client, :action_choice, nil)
  def enter(%States.Authentication{substate: substate}, network_client), do: enter_substate(substate, network_client)

  def receive(%States.Authentication{substate: substate, data: data}, network_client, raw_message) do
    message = String.trim_trailing(raw_message)
    case message do
      "" -> :ok
      message -> parse_message(substate, network_client, data, message)
    end
  end

  def exit(_state, _network_client), do: :ok


  defp switch_substate(network_client, substate, data) do
    Client.switch_state(network_client, States.Authentication.state(substate, data))
  end


  defp enter_substate(:action_choice, network_client), do: Client.transmit(network_client, "Would you like to login or register? ")
  defp enter_substate(:login_username, network_client), do: Client.transmit(network_client, "username: ")
  defp enter_substate(:login_password, network_client), do: Client.transmit(network_client, "password: ")
  defp enter_substate(:register_username, network_client), do: Client.transmit(network_client, "username: ")
  defp enter_substate(:register_password, network_client), do: Client.transmit(network_client, "password: ")


  defp parse_message(:action_choice, network_client, _data, <<char::utf8, _rest::binary>>) do
    case char do
      ?r -> switch_substate(network_client, :register_username, nil)
      ?l -> switch_substate(network_client, :login_username, nil)
      _ -> switch_substate(network_client, :action_choice, nil)
    end
  end

  defp parse_message(:register_username, network_client, _data, username), do: switch_substate(network_client, :register_password, username)
  defp parse_message(:register_password, network_client, username, password) do
    case ChatServer.DB.User.register(username, password) do
      :ok ->
        join_chat(network_client, username)
      {:error, error} ->
        Client.transmit(network_client, register_error(error) <> "\n")
        switch_substate(network_client, :action_choice, nil)
    end
  end

  # I know that this is identical to the register pretty much
  # But in real world there would be some differences realistically so keeping these apart
  defp parse_message(:login_username, network_client, _data, username), do: switch_substate(network_client, :login_password, username)
  defp parse_message(:login_password, network_client, username, password) do
    case ChatServer.DB.User.login(username, password) do
      :ok ->
        join_chat(network_client, username)
      {:error, error} ->
        Client.transmit(network_client, login_error(error) <> "\n")
        switch_substate(network_client, :action_choice, nil)
    end
  end

  defp register_error(:invalid_username), do: "Invalid username!"
  defp register_error(:already_exists), do: "A user with this username already exists!"
  defp register_error(_error), do: "Unknown error registering."

  defp login_error(:user_not_found), do: "User not found."
  defp login_error(:wrong_password), do: "Wrong password!"
  defp login_error(_error), do: "Unknown error logging in."

    
  defp join_chat(network_client, username) do
    if Clients.has_username?(username) do
      Client.transmit(network_client, "Looks like you are already online!\n")
      switch_substate(network_client, :action_choice, nil)
    else
      Client.switch_state(network_client, States.Chat.state(username))
    end
  end
end
