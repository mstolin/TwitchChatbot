defmodule TwitchChatbot do
  defmodule TwitchChatbot.Config do
    defstruct ~w|bot_name channel token socket|a
  end

  use GenServer
  require Logger

  # Client

  def start_link(%{channel: _channel, token: _token, bot_name: _bot_name} = config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  def init(%{channel: channel, token: token, bot_name: bot_name}) do
    {:ok,
     %TwitchChatbot.Config{
       bot_name: bot_name,
       channel: channel,
       token: token
     }, {:continue, :connect}}
  end

  # Server

  @impl true
  def handle_continue(
        :connect,
        config
      ) do
    case Client.connect() do
      {:ok, socket} ->
        {:noreply, %TwitchChatbot.Config{config | socket: socket}, 0}

      {:error, reason} ->
        IO.puts(reason)
        {:noreply, config}
    end
  end

  @impl true
  def handle_info(_msg, config) do
    Client.authenticate(%{socket: config.socket, token: config.token, bot_name: config.bot_name})
    Client.join_channel(%{socket: config.socket, channel: config.channel})

    listen(config.socket, config.channel)
  end

  defp listen(socket, channel) do
    case Client.listen_rec(%{socket: socket}) do
      response when is_binary(response) ->
        # cond do
        #  String.starts_with?(data, "PING") ->
        #    {:ok}

        #  String.contains?(data, "PRIVMSG") ->
        #    {:ok}

        #  true ->
        #    nil
        # end

        parse_response(response)

        listen(socket, channel)
    end
  end

  defp parse_response(response) when is_binary(response) do
    cond do
      String.contains?(response, "PRIVMSG") ->
        message = response |> String.split(":", parts: 3) |> List.last()
        parse_message(message)

      true ->
        nil
    end
  end

  defp parse_message(message) when is_binary(message) do
    cond do
      String.starts_with?(message, "!") ->
        Logger.info("MESSAGE (#{message}) IS COMMAND")

      true ->
        nil
    end
  end
end
