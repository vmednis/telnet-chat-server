defmodule ChatServer.Command.Ping do
  def apply(username, _cmd, []) do
    ChatServer.NetworkClients.transmit(username, "Pong")
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /ping\nCheck if the server is still responding."
end
