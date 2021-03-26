defmodule Server do
  use Application

  def start(_type, _args) do
    children = []

    TwitchChatbot.Supervisor.start_link(children)
  end
end
