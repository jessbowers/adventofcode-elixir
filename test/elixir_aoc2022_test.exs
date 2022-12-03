defmodule ElixirAoc2022Test do
  use ExUnit.Case
  doctest ElixirAoc2022

  test "greets the world" do
    assert ElixirAoc2022.hello() == :world
  end

  test "day 1 part 1" do
    assert ElixirAoc2022.Y2020.D1.p1() == 0
  end
end
