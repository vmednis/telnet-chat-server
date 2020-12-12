defmodule ChatServer.Command.Say do
  def apply(username, _cmd, [message]) do
    ChatServer.NetworkClients.broadcast(username <> ": " <> message)
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /say <message>\nSends a message to everyone on the server."
end
