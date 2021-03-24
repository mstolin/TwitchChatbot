defmodule ElixirTwitchChatbotTest do
  use ExUnit.Case
  doctest ElixirTwitchChatbot

  test "greets the world" do
    assert ElixirTwitchChatbot.hello() == :world
  end
end
