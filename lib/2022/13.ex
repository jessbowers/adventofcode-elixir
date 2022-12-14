import AOC

aoc 2022, 13 do
  #
  def p1(i), do: parse_json(i) |> validate_pairs() |> score()
  def p2(i), do: parse_json(i) |> add_dividers() |> sort_packets() |> find_dividers()

  # Parsing

  # TODO: fix manual parsing - has bug w/ numbers with double digits!

  # # parsing end state
  # defp parse_line(<<>>, [stack]), do: stack

  # # parsing, open brace
  # defp parse_line(<<?[, tail::bytes>>, stack), do: parse_line(tail, [stack])

  # # parsing, number
  # defp parse_line(<<n, tail::bytes>>, stack) when n >= ?0 and n <= ?9,
  #   do: parse_line(tail, [n - 48 | stack])

  # # ignore comma
  # defp parse_line(<<?,, tail::bytes>>, stack), do: parse_line(tail, stack)

  # # closing brace
  # defp parse_line(<<?], tail::bytes>>, stack) do
  #   [stack | children] = stack |> Enum.reverse()
  #   parse_line(tail, [children | stack])
  # end

  # defp parse_pair(input) do
  #   input
  #   |> String.split("\n", trim: true)
  #   |> Enum.map(&parse_line(&1, []))
  #   |> List.to_tuple()
  # end

  # defp parse(input) do
  #   input
  #   |> String.split("\n\n", trim: true)
  #   |> Enum.map(&parse_pair/1)
  # end

  defp parse_json(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.flat_map(fn p ->
      p |> String.split("\n") |> Enum.map(&JSON.decode!/1)
    end)
  end

  # Validation
  defp compare_pair({left, right}) when is_list(left) and is_list(right) do
    case {left, right} do
      {[], []} ->
        0

      {[], _} ->
        1

      {_, []} ->
        -1

      {[h1 | tail1], [h2 | tail2]} ->
        case compare_pair({h1, h2}) do
          0 -> compare_pair({tail1, tail2})
          res -> res
        end
    end
  end

  defp compare_pair({left, right}) when is_list(left), do: compare_pair({left, [right]})
  defp compare_pair({left, right}) when is_list(right), do: compare_pair({[left], right})

  defp compare_pair({left, right}) do
    cond do
      left < right -> 1
      left == right -> 0
      left > right -> -1
    end
  end

  defp validate_pairs(list) do
    list
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(&compare_pair/1)
    |> Enum.map(&(&1 > 0))
  end

  defp score(list),
    do:
      list
      |> Enum.with_index(1)
      |> Enum.filter(&elem(&1, 0))
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

  defp add_dividers(list) do
    [[[2]], [[6]] | list]
  end

  defp sort_packets(list) do
    list
    |> Enum.with_index(1)
    |> Enum.sort(fn {x, _}, {y, _} -> compare_pair({x, y}) >= 0 end)
  end

  defp find_dividers(list) do
    list
    |> Enum.map(&elem(&1, 1))
    |> Enum.with_index(1)
    |> Enum.filter(&(elem(&1, 0) <= 2))
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end
end
