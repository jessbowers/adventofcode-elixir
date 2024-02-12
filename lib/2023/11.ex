import AOC
alias AdventOfCode.Helpers.Transformers
alias AdventOfCode.Algorithms.Grid

aoc 2023, 11 do
  def p1(input), do: input |> parse() |> expand(1) |> shortest_paths() |> score()
  def p2(input), do: input |> parse() |> expand(1_000_000 - 1) |> shortest_paths() |> score()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&String.graphemes/1)
  end

  # expand the empty rows, in the dimension (0 = x, 1 = y)
  # lines are [{{x, y}, val},....]
  def expand_empty(lines, space) do
    lines = lines |> Enum.group_by(fn {{x, _}, _} -> x end) |> Enum.sort()

    for {_i, line} <- lines, reduce: {[], 0} do
      {tl, offset} ->
        case Enum.all?(line, &(elem(&1, 1) == ".")) do
          true ->
            {tl, offset + space}

          false ->
            line =
              line
              |> Enum.map(fn {{x, y}, val} -> {{y, x + offset}, val} end)

            {[line | tl], offset}
        end
    end
    |> elem(0)
    |> List.flatten()
  end

  def expand(lines, space) do
    lines
    |> Grid.grid2d()
    |> expand_empty(space)
    |> expand_empty(space)
  end

  def galaxies(uni) do
    uni
    |> Enum.filter(&(elem(&1, 1) == "#"))
    |> Enum.map(fn {{x, y}, _} -> {x, y} end)
    |> Enum.sort()
  end

  def shortest_path(gals) do
    # manhattan dist
    for {{x1, y1}, i} <- gals |> Enum.with_index() do
      for {x2, y2} <- gals |> Enum.drop(i) do
        abs(x1 - x2) + abs(y1 - y2)
      end
      |> Enum.sum()
    end
  end

  def shortest_paths(uni) do
    uni
    |> galaxies()
    |> shortest_path()
  end

  def score(uni), do: uni |> Enum.sum()
end
