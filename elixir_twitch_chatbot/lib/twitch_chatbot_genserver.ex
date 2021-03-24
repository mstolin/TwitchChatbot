defmodule TwitchChatbot.GenServer do
  use GenServer

  # Client

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:ok, socket} = connect()

    authenticate(%{socket: socket})
    join_channel(%{socket: socket, channel: "gtimetv"})

    listen_rec(%{socket: socket})

    {:ok, %{socket: socket}, 0}
  end

  defp connect() do
    :gen_tcp.connect('irc.chat.twitch.tv', 6667, [:binary, {:active, false}, {:packet, :line}])
  end

  defp authenticate(%{socket: socket} = state) do
    token = ""
    bot_name = "schlamasssel"

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
