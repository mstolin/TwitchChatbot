defmodule ElixirTwitchChatbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_twitch_chatbot,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :dev,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Server, []}
    ]
  end

  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
