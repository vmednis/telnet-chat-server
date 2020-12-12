defmodule ChatServer.Command.Nonexistent do
  def apply(username, cmd, args) do
    message =
      "No such command as /" <>
        cmd <> " with " <> Integer.to_string(length(args)) <> " arguments found."

    ChatServer.NetworkClients.transmit(username, message)
  end

  def help(), do: "This command does not exist."
end
