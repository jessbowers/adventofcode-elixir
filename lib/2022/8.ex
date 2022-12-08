import AOC

aoc 2022, 8 do
  def p1(input), do: parse(input) |> find_visible()
  def p2(input), do: parse(input) |> find_scenic_score()

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line |> String.codepoints() |> Enum.map(&String.to_integer/1)
  end

  defp find_visible(rows) do
    rows
    |> Enum.map(fn r -> r |> Enum.map(&{&1, false}) end)
    |> Enum.map(&find_visible_in_row/1)
    |> Enum.map(&find_visible_in_row/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&find_visible_in_row/1)
    |> Enum.map(&find_visible_in_row/1)
    |> List.flatten()
    |> Enum.filter(&elem(&1, 1))
    |> Enum.count()
  end

  defp find_visible_in_row(list) do
    list
    |> Enum.reduce({-1, []}, fn
      {height, is_vis}, {max, tail} ->
        cond do
          height > max -> {height, [{height, true} | tail]}
          height <= max -> {max, [{height, is_vis} | tail]}
        end
    end)
    |> then(fn {_, list} -> list end)
  end

  defp find_scenic_score(rows) do
    rows
    |> Enum.map(fn r -> r |> Enum.map(&{&1, []}) end)
    |> Enum.map(&calc_scenic/1)
    |> Enum.map(&calc_scenic/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&calc_scenic/1)
    |> Enum.map(&calc_scenic/1)
    |> List.flatten()
    |> Enum.map(fn {_h, ss} -> Enum.product(ss) end)
    |> Enum.sort(:desc)
    |> Enum.at(0)
  end

  defp calc_scenic(row) do
    # given an h, x (height of tree, x val)
    # look up the map for the h
    # keep track of h[0-9] tree in that direction, backwards
    # filter h1 >= h, sort by x
    # nearest x is our scenic blocker
    row
    |> Enum.with_index()
    |> Enum.reduce({%{}, []}, fn
      {{h, stail}, idx}, {view_map, tail} ->
        tree =
          view_map
          |> Enum.filter(fn {kh, _} -> kh >= h end)
          |> Enum.sort_by(fn {_, x} -> x end, :desc)
          |> Enum.at(0, {nil, 0})
          |> then(fn
            {_, x} ->
              scenic = idx - x
              {{h, [scenic | stail]}, idx}
          end)

        # insert our tree into a key w/ our height
        view_map = view_map |> Map.put(h, idx)
        {view_map, [tree | tail]}
    end)
    |> then(fn {_, list} -> list end)
    |> Enum.map(fn {t, _idx} -> t end)
  end
end
