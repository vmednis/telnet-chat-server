defmodule ChatServer.NetworkManager do
  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accpeting connections on port #{port}")
    acceptor(socket)
  end

  defp acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    client_ref = make_ref()

    network_client = ChatServer.NetworkClient.init_struct(client_ref, client)
    {:ok, pid} = ChatServer.NetworkClient.start_link(network_client)

    {:ok, rx} =
      Task.Supervisor.start_child(ChatServer.ReceiverSupervisor, fn -> receiver(client, pid) end)

    :ok = :gen_tcp.controlling_process(client, rx)

    acceptor(socket)
  end

  def close(socket) do
    :gen_tcp.close(socket)
  end

  def transmit(socket, message) when is_list(message) do
    transmit(socket, List.to_string(message))
  end

  def transmit(socket, message) when is_binary(message) do
    # escape FF bytes as they are used in telnet for commands
    encoded_message = :binary.replace(message, <<0xFF>>, <<0xFF, 0xFF>>, [:global])
    :gen_tcp.send(socket, encoded_message)
  end

  defp receiver(socket, network_client) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        ChatServer.NetworkClient.receive(network_client, message)
        receiver(socket, network_client)

      _ ->
        ChatServer.NetworkClient.exit(network_client)
    end
  end
end
