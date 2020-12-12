defmodule ChatServer.Command.Tell do
  def apply(from, _cmd, [to, message]) do
    if ChatServer.NetworkClients.has_username?(to) do
      if from == to do
        ChatServer.NetworkClients.transmit(from, "Are you trying to message yourself? Pathetic.")
      else
        msg = IO.ANSI.cyan() <> from <> " tells " <> to <> ": " <> message <> IO.ANSI.reset()
        ChatServer.NetworkClients.transmit(from, msg)
        ChatServer.NetworkClients.transmit(to, msg)
      end
    else
      ChatServer.NetworkClients.transmit(from, "This user is not online.")
    end
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /say <recipient> <message>\nSends a message to the recipient only."
end
