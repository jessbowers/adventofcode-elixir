import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 8 do
  def p1(input), do: parse(input) |> do_all_moves("AAA", &(&1 == "ZZZ"))
  def p2(input), do: parse(input) |> move_all_ghosts()

  def parse(input) do
    [moves, map_lines] = input |> Transformers.sections()

    moves =
      moves
      |> String.to_charlist()
      |> Enum.map(fn
        ?L -> 0
        ?R -> 1
      end)

    map =
      map_lines
      |> Transformers.lines()
      |> Enum.map(&parse_map/1)
      |> Map.new()

    {moves, map}
  end

  def parse_map(line) do
    [node, left, right] =
      ~r/(\w+) = \((\w+), (\w+)\)/ |> Regex.run(line, capture: :all_but_first)

    {node, {left, right}}
  end

  # move all moves and end when target = key
  def do_all_moves({moves, map}, src, target_fn, count \\ 0) do
    # do the moves, cycle every move, go to the key -> (left, right), picking door based on the move value
    loc =
      moves
      |> Enum.reduce(src, fn i, key -> map |> Map.get(key) |> then(&elem(&1, i)) end)

    # increase the total count
    count = count + length(moves)

    cond do
      # test for completion
      target_fn.(loc) -> count
      # not complete yet, keep moving
      true -> do_all_moves({moves, map}, loc, target_fn, count)
    end
  end

  # Least Common Multiple, lcm = x * y / gcd(x, y)
  def lcm(x, y), do: Integer.extended_gcd(x, y) |> elem(0) |> then(&round(x * y / &1))

  # a bunch of ghosts start at all doors ending in A, moving until they hit doors that end in Z
  def move_all_ghosts({moves, map}) do
    # keys that end with A
    # for all paths, see what the cycle is to reach a key that ends with Z
    cycles =
      map
      |> Map.keys()
      |> Enum.filter(&String.ends_with?(&1, "A"))
      |> Enum.map(fn src -> do_all_moves({moves, map}, src, &String.ends_with?(&1, "Z")) end)

    # find the least common multiple of all the cycles
    # https://en.wikipedia.org/wiki/Least_common_multiple
    cycles |> Enum.reduce(&lcm/2)
  end
end
