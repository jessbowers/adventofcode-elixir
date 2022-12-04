import AOC

aoc 2022, 3 do
  def p1(input), do: parse(input) |> sacks() |> score_duplicates()
  def p2(input), do: parse(input) |> groups() |> score_duplicates()

  defp find_commons(list) do
    list
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.at(0, nil)
  end

  defp score_item(item) do
    if item >= ?a do
      item - ?a + 1
    else
      item - ?A + 27
    end
  end

  defp parse(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  defp split_compartments(items),
    do: items |> Enum.split(div(Enum.count(items), 2)) |> Tuple.to_list()

  defp sacks(s), do: s |> Enum.map(&split_compartments/1)
  defp groups(s), do: s |> Enum.chunk_every(3)

  defp score_duplicates(groups) do
    groups
    |> Enum.map(&find_commons/1)
    |> Enum.map(&score_item/1)
    |> Enum.sum()
  end
end
