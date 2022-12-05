import AOC

aoc 2022, 5 do
  def p1(i), do: parse(i) |> do_moves(&p1_sorter/1) |> print_tops()
  def p2(i), do: parse(i) |> do_moves(&p2_sorter/1) |> print_tops()

  defp stack_line(["[", n, "]"] ++ [_sp | tail]), do: [n] ++ stack_line(tail)
  defp stack_line(["[", n, "]"]), do: [n]
  defp stack_line([" ", " ", " "] ++ [_sp | tail]), do: [[]] ++ stack_line(tail)
  defp stack_line([" ", " ", " "]), do: [[]]
  defp stack_line([" ", n, " "] ++ [_sp | tail]), do: n ++ stack_line(tail)
  defp stack_line([" ", n, " "]), do: [n]

  defp parse_stack_line(line) do
    line
    |> String.graphemes()
    |> stack_line()
  end

  defp parse_stacks(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.drop(-1)
    |> Enum.map(&parse_stack_line/1)
    # transpose
    |> Enum.zip_with(& &1)
    |> Enum.map(&List.flatten/1)
  end

  defp parse_move_line(line) do
    ~r/move (\d+) from (\d) to (\d)/
    |> Regex.run(line)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_moves(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_move_line/1)
  end

  defp parse(input) do
    [header, body] = input |> String.split("\n\n", trim: true)
    {parse_stacks(header), parse_moves(body)}
  end

  defp split_source(stacks, src) do
    stacks |> Enum.split(src - 1)
  end

  defp extract_items({heads, [stack | tail]}, n) do
    {items, s} = stack |> Enum.split(n)
    {heads ++ [s] ++ tail, items}
  end

  defp p1_sorter(i), do: Enum.reverse(i)
  defp p2_sorter(i), do: i
  defp order_items({stacks, items}, sorter), do: {stacks, sorter.(items)}

  defp insert_target({stacks, items}, tgt) do
    {heads, [stack | tail]} = stacks |> Enum.split(tgt - 1)
    heads ++ [items ++ stack] ++ tail
  end

  defp move({n, src, tgt}, stacks, sorter) do
    stacks
    |> split_source(src)
    |> extract_items(n)
    |> order_items(sorter)
    |> insert_target(tgt)
  end

  defp do_moves({stacks, moves}, sorter),
    do: moves |> Enum.reduce(stacks, fn i, a -> move(i, a, sorter) end)

  defp print_tops(stacks) do
    stacks
    |> Enum.map(&Enum.at(&1, 0))
    |> List.to_string()
  end
end
