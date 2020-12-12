defmodule ChatServer.Command.Quit do
  def apply(username, _cmd, []) do
    ChatServer.NetworkClients.retrieve(username)
    |> ChatServer.NetworkClient.quit()
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /quit\nLeave the chat."
end
