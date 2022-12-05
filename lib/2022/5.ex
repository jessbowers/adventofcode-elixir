import AOC

aoc 2022, 5 do
  def p1(i), do: parse(i) |> do_moves() |> print_tops()

  defp stack_line(["[", n, "]"] ++ [_sp | tail]), do: [n] ++ stack_line(tail)
  defp stack_line(["[", n, "]"]), do: [n]
  defp stack_line([" ", " ", " "] ++ [_sp | tail]), do: [[]] ++ stack_line(tail)
  defp stack_line([" ", " ", " "]), do: [[]]
  defp stack_line([" ", n, " "] ++ [_sp | tail]), do: n ++ stack_line(tail)
  defp stack_line([" ", n, " "]), do: [n]

  defp parse_stacks(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.at(0)
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.reverse()
    |> Enum.map(fn s ->
      s |> String.graphemes() |> stack_line()
    end)
    # transpose
    |> Enum.zip_with(& &1)
    |> Enum.map(&List.flatten/1)
  end

  defp parse_moves(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.at(1)
    |> String.split("\n", trim: true)
    |> Enum.map(fn ln ->
      Regex.run(
        ~r/move (\d+) from (\d) to (\d)/,
        ln
      )
    end)
    |> Enum.map(fn [_, x, y, z] ->
      [x, y, z]
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp parse(input) do
    stacks = input |> parse_stacks()
    moves = input |> parse_moves()
    {stacks, moves}
  end

  defp split_source(stacks, src) do
    stacks |> Enum.split(src - 1)
  end

  defp extract_items({heads, [stack | tail]}, n) do
    {items, s} = stack |> Enum.split(n)
    {heads ++ [s] ++ tail, Enum.reverse(items)}
  end

  defp insert_target({stacks, items}, tgt) do
    {heads, [stack | tail]} = stacks |> Enum.split(tgt - 1)
    heads ++ [items ++ stack] ++ tail
  end

  defp move({n, src, tgt}, stacks) do
    stacks
    |> split_source(src)
    |> extract_items(n)
    |> insert_target(tgt)
  end

  defp do_moves({stacks, moves}) do
    moves
    |> Enum.reduce(stacks, &move/2)
  end

  defp print_tops(stacks) do
    stacks
    |> Enum.map(&Enum.at(&1, 0))
    |> List.to_string()
  end
end
