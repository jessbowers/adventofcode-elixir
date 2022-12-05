import AOC

aoc 2022, 4 do
  def p1(input), do: parse(input) |> count_intersects()
  def p2(input), do: parse(input) |> count_overlaps()

  defp parse_range(s),
    do: s |> String.split("-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

  defp parse_pair(s), do: s |> String.split(",") |> Enum.map(&parse_range/1)

  defp parse(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_pair/1)
  end

  defp test_intersect([{minX, maxX}, {minY, maxY}]) when minX <= minY and maxX >= maxY, do: 1
  defp test_intersect([{minX, maxX}, {minY, maxY}]) when minY <= minX and maxY >= maxX, do: 1
  defp test_intersect(_), do: 0

  defp test_overlap([{minX, maxX}, {minY, _maxY}]) when minX <= minY and minY <= maxX, do: 1
  defp test_overlap(_), do: 0

  defp count_intersects(list), do: list |> Enum.map(&test_intersect/1) |> Enum.sum()

  defp count_overlaps(list) do
    list
    |> Enum.map(fn pair -> pair |> Enum.sort(fn {x1, _}, {y1, _} -> x1 < y1 end) end)
    |> Enum.map(&test_overlap/1)
    |> Enum.sum()
  end
end
