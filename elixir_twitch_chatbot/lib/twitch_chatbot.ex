defmodule TwitchChatbot do
  defmodule TwitchChatbot.Config do
    defstruct ~w|bot_name channel token|a
  end

  use GenServer

  # Client

  def start_link(%{channel: _channel, token: _token, bot_name: _bot_name} = config) do
    # name: process_name(channel)
    GenServer.start_link(__MODULE__, config)
  end

  def init(%{channel: channel, token: token, bot_name: bot_name}) do
    {:ok, socket} = connect()

    authenticate(%{socket: socket, token: token, bot_name: bot_name})
    join_channel(%{socket: socket, channel: channel})

    listen_rec(%{socket: socket})

    {:ok, %{socket: socket}, 0}
  end

  defp process_name(channel) do
    {:via, Registry, {TwitchBotRegistry, "#{channel}"}}
  end

  defp connect() do
    :gen_tcp.connect('irc.chat.twitch.tv', 6667, [:binary, {:active, false}, {:packet, :line}])
  end

  defp authenticate(%{socket: socket, token: token, bot_name: bot_name} = state) do
    :gen_tcp.send(socket, "PASS oauth:#{token} \r\n")
    :gen_tcp.send(socket, "NICK #{bot_name} \r\n")

    state
  end

  defp join_channel(%{socket: socket, channel: channel} = state) do
    :gen_tcp.send(socket, "JOIN ##{channel} \r\n")

    state
  end

  defp listen_rec(%{socket: socket} = state) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        cond do
          String.starts_with?(data, "PING") -> IO.puts("PING!!")
          String.contains?(data, "PRIVMSG") -> IO.puts("MESSAGE #{data}")
          true -> IO.puts("== DATA RECEIVED ==\r\n" <> String.Chars.to_string(data))
        end

        listen_rec(state)

      {:error, :closed} ->
        IO.puts("== CLOSED ==")
        :gen_tcp.close(socket)
    end
  end

  # Server

  def handle_info(_, state) do
    IO.puts("== HANDLE INFO ==")
    IO.inspect(state)
    {:noreply, state}
  end
end
