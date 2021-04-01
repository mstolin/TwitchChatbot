defmodule TwitchChatbot.Supervisor do
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_chatbot(config) do
    # TwitchChatbot.Supervisor.start_chatbot(%{channel: "papaplatte", bot_name: "schlamasssel", token: "o3clts23huuwa0exsc90vu3lqno6zc"})
    spec = {
      TwitchChatbot,
      config
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
