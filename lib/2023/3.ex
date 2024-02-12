import AOC

aoc 2023, 3 do
  def p1(input), do: parse(input) |> read_valid_parts() |> score()
  def p2(input), do: parse(input) |> find_gears()

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_parts_symbols/1)
  end

  # parse a line into the parts and symbols on that line
  def parse_parts_symbols({line, y}) do
    nums =
      Regex.scan(~r/\d+/, line, return: :index)
      |> List.flatten()
      |> Enum.map(fn {i, n} ->
        {:num, {i, n, y}, line |> String.slice(i, n) |> String.to_integer()}
      end)

    syms =
      Regex.scan(~r/[^\d^\.]/, line, return: :index)
      |> List.flatten()
      |> Enum.map(fn {i, n} ->
        {:sym, {i, n, y}, line |> String.slice(i, n)}
      end)

    {nums, syms}
  end

  # sort by x
  def sort_x({_, {x1, _, _}, _}, {_, {x2, _, _}, _}), do: x1 < x2

  # combine multiple symbol lists to a single sorted list
  def combine_syms(syms, prev_syms),
    do: [syms | prev_syms] |> List.flatten() |> Enum.sort(&sort_x/2)

  # Read all valid parts
  def read_valid_parts(list), do: list |> filter_nums([], []) |> List.flatten()

  # first line
  def filter_nums([{n1, s1} | tl], [], []), do: filter_nums(tl, [s1], n1)
  # last line
  def filter_nums([], psyms, nums), do: nums |> good_nums(combine_syms([], psyms))
  # other lines, except last
  def filter_nums([{n1, s1} | tl], psyms, nums) do
    # find good items on this line
    goods = nums |> good_nums(combine_syms(s1, psyms))
    # add to the result list, moving on to the next pair, truncating the psyms
    [goods | filter_nums(tl, [s1 | Enum.take(psyms, 1)], n1)]
  end

  # Find good part numbers, the ones close to a symbol

  # ran out of numbers
  def good_nums([], _), do: []

  # ran out of symbols
  def good_nums(_, []), do: []

  def good_nums([num | tl], [sym | sym_tl]) do
    {{:num, {x1, n, _}, val}, {:sym, {x2, _, _}, _}} = {num, sym}

    case {x1, x2} do
      {x1, x2} when x2 < x1 - 1 ->
        good_nums([num | tl], sym_tl)

      {x1, x2} when x2 <= x1 + n ->
        [{val, sym} | good_nums(tl, [sym | sym_tl])]

      _ ->
        good_nums(tl, [sym | sym_tl])
    end
  end

  def score(list) do
    list |> Enum.map(fn {n, _} -> n end) |> Enum.sum()
  end

  def find_gears(list) do
    list
    |> Enum.map(fn {n, s} ->
      s = s |> Enum.filter(fn {:sym, _, val} -> val == "*" end)
      {n, s}
    end)
    |> read_valid_parts()
    |> filter_only_dupe_syms()
  end

  def filter_only_dupe_syms(list) do
    list
    |> Enum.reduce(Map.new(), fn {val, {:sym, xy, _}}, acc ->
      acc
      |> Map.get_and_update(xy, fn
        nil -> {nil, [val]}
        ary -> {ary, [val | ary]}
      end)
      |> elem(1)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(fn vals -> length(vals) == 2 end)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
  end
end
