import AOC

aoc 2022, 6 do
  def p1(i), do: parse(i) |> search(4)
  def p2(i), do: parse(i) |> search(14)

  defp parse(input), do: input |> String.codepoints()

  defp search(list, max) do
    list
    |> Enum.with_index()
    |> find_unique([], max)
  end

  defp find_unique([{char, idx} | tail], prev, n) do
    # add the next char to the list, then truncate the list
    list = [char | prev] |> Enum.take(n)

    # test for a unique n chars
    case length(Enum.uniq(list)) do
      ^n -> idx + 1
      _ -> find_unique(tail, list, n)
    end
  end
end
