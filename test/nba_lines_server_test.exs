defmodule NbaLinesServerTest do
  use ExUnit.Case
  doctest NbaLinesServer

  test "greets the world" do
    assert NbaLinesServer.hello() == :world
  end
end
