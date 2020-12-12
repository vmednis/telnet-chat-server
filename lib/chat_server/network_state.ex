defprotocol ChatServer.NetworkState do
  def enter(state, network_client)
  def receive(state, network_client, message)
  def exit(state, network_client)
end
