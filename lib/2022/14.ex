import AOC

aoc 2022, 14 do
  def p1(i), do: parse(i) |> pour_to_abyss()
  def p2(i), do: parse(i) |> pour_to_floor()

  defp parse_pair(pair) do
    pair
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp add_line(pt, {nil, map}), do: {pt, map}

  defp add_line({x2, y2}, {{x1, y1}, map}) do
    newmap =
      x1..x2
      |> Enum.to_list()
      |> Enum.map(fn
        x ->
          y1..y2
          |> Enum.to_list()
          |> Enum.map(fn y -> {{x, y}, true} end)
      end)
      |> List.flatten()
      |> Map.new()
      |> Map.merge(map)

    {{x2, y2}, newmap}
  end

  defp parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(&parse_pair/1)
    |> Enum.reduce({nil, %{}}, &add_line/2)
    |> elem(1)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  defp down_from({x, y}, map, {maxx, _}) do
    [{0, 1}, {-1, 1}, {1, 1}]
    |> Enum.map(fn {dx, dy} -> {dx + x, dy + y} end)
    |> Enum.map(fn k -> {k, Map.get(map, k, false)} end)
    |> Enum.reject(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(&(elem(&1, 1) >= maxx))
  end

  defp pour_grain(map, xy, max_xy) do
    down_xy = down_from(xy, map, max_xy) |> Enum.at(0)

    case down_xy do
      nil ->
        {:stop, xy}

      {_, y} when y > elem(max_xy, 1) ->
        {:abyss, down_xy}

      dxy ->
        pour_grain(map, dxy, max_xy)
    end
  end

  defp pour_sand(map, entry_xy, max_xy, n) do
    case pour_grain(map, entry_xy, max_xy) do
      {:abyss, _xy} ->
        n - 1

      {:stop, ^entry_xy} ->
        n

      {:stop, xy} ->
        map = map |> Map.put(xy, true)
        pour_sand(map, entry_xy, max_xy, n + 1)
    end
  end

  defp pour(map, max) do
    pour_sand(map, {500, 0}, max, 1)
  end

  defp pour_to_abyss(map) do
    pour(map, max_floor_abyss(map))
  end

  defp pour_to_floor(map) do
    {floor_y, _maxy} = max_floor_abyss(map)
    pour(map, {floor_y, floor_y + 1})
  end

  defp max_floor_abyss(map) do
    map_keys = map |> Map.keys()
    abyss_y = map_keys |> Enum.max_by(fn {_, y} -> y end) |> elem(1)
    {abyss_y + 2, abyss_y}
  end

  # defp draw_map(map, {maxx, maxy}) do
  #   0..maxy
  #   |> Enum.map(fn y ->
  #     494..maxx
  #     |> Enum.map(fn x ->
  #       if Map.get(map, {x, y}, false), do: "#", else: "."
  #     end)
  #   end)
  #   # |> Enum.chunk_every(40)
  #   |> Enum.map(&Enum.join/1)
  #   |> Enum.map(&IO.puts/1)
  # end
end
