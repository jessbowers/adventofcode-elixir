import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 18 do
  def p1(i), do: parse1(i) |> dig()
  def p2(i), do: parse2(i) |> dig()

  def parse1(input) do
    input
    |> Transformers.lines()
    |> Enum.map(fn line -> line |> String.split(" ") end)
    |> Enum.map(fn [d, s, _] -> {d, s |> String.to_integer()} end)
  end

  def parse2(input) do
    re = ~r/\w+ \w+ \(#(\w\w\w\w\w)(\d)\)/

    input
    |> Transformers.lines()
    |> Enum.map(fn line ->
      Regex.run(re, line)
      |> then(fn [_, n, d] ->
        [String.to_integer(d), String.to_integer(n, 16)]
      end)
    end)
    |> Enum.map(fn
      [0, n] -> {"R", n}
      [1, n] -> {"D", n}
      [2, n] -> {"L", n}
      [3, n] -> {"U", n}
    end)
  end

  def dig(moves) do
    points =
      moves
      |> Enum.reduce(
        [{0, 0}],
        # convert to list of points
        fn
          {"R", n}, [{x, y} | _] = acc -> [{x + n, y} | acc]
          {"L", n}, [{x, y} | _] = acc -> [{x - n, y} | acc]
          {"U", n}, [{x, y} | _] = acc -> [{x, y - n} | acc]
          {"D", n}, [{x, y} | _] = acc -> [{x, y + n} | acc]
        end
      )
      |> Enum.drop(-1)

    inner_area =
      points
      |> Enum.reduce({0, []}, fn
        pt, {a, []} -> {a, [pt]}
        {x1, y1} = pt, {a, [{x2, y2} | _] = acc} -> {a + (y1 + y2) * (x1 - x2), [pt | acc]}
      end)
      |> then(fn {a, _} -> a * 0.5 end)

    outside_area =
      moves
      |> Enum.reduce(0, fn {_, n}, a -> a + n end)
      |> then(fn a -> a * 0.5 + 1.0 end)

    trunc(inner_area + outside_area)
  end
end
