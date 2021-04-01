defmodule Client do
  require Logger

  def connect() do
    :gen_tcp.connect('irc.chat.twitch.tv', 6667, [:binary, {:active, false}, {:packet, :line}])
  end

  def authenticate(%{socket: socket, token: token, bot_name: bot_name} = config) do
    :gen_tcp.send(socket, "PASS oauth:#{token} \r\n")
    :gen_tcp.send(socket, "NICK #{bot_name} \r\n")
    config
  end

  def join_channel(%{socket: socket, channel: channel} = config) do
    :gen_tcp.send(socket, "JOIN ##{channel} \r\n")
    config
  end

  def listen_rec(%{socket: socket}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data

      {:error, :closed} ->
        Logger.error("Close Connection")
        :gen_tcp.close(socket)
    end
  end
end
