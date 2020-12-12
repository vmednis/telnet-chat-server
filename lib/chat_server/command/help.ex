defmodule ChatServer.Command.Help do
  def apply(username, _cmd, []) do
    commands =
      "Available commands: " <>
        Enum.join(ChatServer.Command.commands(), ", ") <> "\nType /help <command> for more info."

    ChatServer.NetworkClients.transmit(username, commands)
  end

  def apply(username, _cmd, [command]) do
    help_text = Kernel.apply(ChatServer.Command.module(command), :help, [])
    ChatServer.NetworkClients.transmit(username, help_text)
  end

  def apply(username, cmd, args), do: ChatServer.Command.Nonexistent.apply(username, cmd, args)

  def help(), do: "Usage: /help [command]\nProvides help about commands."
end
