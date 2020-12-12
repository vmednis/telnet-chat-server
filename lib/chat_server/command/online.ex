defmodule ChatServer.Command.Online do
  def apply(username, _cmd, []) do
    user_list = ChatServer.NetworkClients.registered_usernames()

    msg =
      "Currently " <>
        Integer.to_string(length(user_list)) <> " users online:\n" <> Enum.join(user_list, ", ")

    ChatServer.NetworkClients.transmit(username, msg)
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /online\nLists all the users online."
end
