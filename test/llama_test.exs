defmodule LlamaTest do
  use ExUnit.Case
  doctest Llama

  test "greets the world" do
    assert Llama.hello() == :world
  end
end
