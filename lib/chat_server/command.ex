defmodule ChatServer.Command do
  @commands %{
    "say" => ChatServer.Command.Say,
    "tell" => ChatServer.Command.Tell,
    "ping" => ChatServer.Command.Ping,
    "online" => ChatServer.Command.Online,
    "help" => ChatServer.Command.Help,
    "quit" => ChatServer.Command.Quit
  }

  def evaluate(username, "/" <> message) do
    {command, args} = parse(message)
    apply(module(command), :apply, [username, command, args])
  end

  def evaluate(username, message) do
    ChatServer.Command.Say.apply(username, "say", [message])
  end

  def module(command) do
    Map.get(@commands, command, ChatServer.Command.Nonexistent)
  end

  def commands() do
    Enum.map(@commands, fn {cmd, _} -> cmd end)
  end

  defp parse(message) do
    [command | args] =
      Regex.scan(~r/("(.*)"|[^\s]+)/u, message)
      |> Enum.map(fn elems -> List.last(elems) end)

    {command, args}
  end
end
