defmodule ElixirAoc2022Test do
  use ExUnit.Case
  # doctest ElixirAoc2022

  test "day 1 part 13 1" do
    input = "[1,3]\n[1,[2]]"
    assert Y2022.D13.p1(input) == 0
  end

  test "day 1 part 13 2" do
    input = "[1,2,[]]\n[1,[2],[]]"
    assert Y2022.D13.p1(input) == 1
  end

  test "day 1 part 13 3" do
    input = "[1,2,[]]\n[3,[0,2],[]]"
    assert Y2022.D13.p1(input) == 1
  end

  test "day 1 part 13 4" do
    input = "[1,2,3,[4,5,6]]\n[1,2,3,[4,5,6,[]]]"
    assert Y2022.D13.p1(input) == 1
  end

  test "day 1 part 13 5" do
    input = "[1,2,3,[4,5,[7]]]\n[1,2,3,[4,5,6]]"
    assert Y2022.D13.p1(input) == 0
  end

  test "day 1 part 13 6" do
    input = "[[1],[2,3,4]]\n[[1],2,3,4]"
    assert Y2022.D13.p1(input) == 1
  end
end
