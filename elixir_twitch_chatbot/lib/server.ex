defmodule Server do
  use Application

  def start(_type, _args) do
    TwitchChatbot.Supervisor.start_link()
  end
end
