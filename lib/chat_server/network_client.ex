defmodule ChatServer.NetworkClient do
  use Agent
  defstruct client_ref: nil, socket: nil, state: nil

  def init_struct(client_ref, socket) do
    %__MODULE__{client_ref: client_ref, socket: socket}
  end

  def start_link(%__MODULE__{} = opts) do
    {:ok, pid} = agent = Agent.start_link(fn -> opts end)
    switch_state(pid, ChatServer.NetworkState.MOTD.state())
    agent
  end

  def switch_state(pid, state) do
    Agent.update(pid, fn client -> %__MODULE__{client | state: state} end)
    ChatServer.NetworkState.enter(state, pid)
  end

  def transmit(pid, message) do
    Agent.get(pid, fn %__MODULE__{socket: socket} = client ->
      ChatServer.NetworkManager.transmit(socket, message)
      client
    end)
  end

  def receive(pid, message) do
    %__MODULE__{state: state} = Agent.get(pid, fn client -> client end)
    ChatServer.NetworkState.receive(state, pid, message)
  end

  def quit(pid) do
    %__MODULE__{socket: socket} = Agent.get(pid, fn client -> client end)
    ChatServer.NetworkManager.close(socket)
  end

  def exit(pid) do
    %__MODULE__{state: state} = Agent.get(pid, fn client -> client end)
    ChatServer.NetworkState.exit(state, pid)
    Agent.stop(pid)
  end
end
