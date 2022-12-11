import AOC

aoc 2022, 9 do
  def p1(input), do: parse(input) |> create_rope(2) |> run_course()
  def p2(input), do: parse(input) |> create_rope(10) |> run_course()

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ~r/(\w) (\d+)/
    |> Regex.run(line)
    |> tl()
    |> then(fn [d, n] -> {String.to_atom(d), String.to_integer(n)} end)
  end

  defp create_rope(moves, knots), do: {moves, List.duplicate({0, 0}, knots)}

  # Move funcions by direction
  defp move_dx(:U), do: fn {x, y} -> {x, y - 1} end
  defp move_dx(:D), do: fn {x, y} -> {x, y + 1} end
  defp move_dx(:L), do: fn {x, y} -> {x - 1, y} end
  defp move_dx(:R), do: fn {x, y} -> {x + 1, y} end

  # move the head of the rope in a direction
  # track tail's path in a map
  defp do_move({direction, n}, {rope, map}) do
    rope
    |> hd()
    |> Stream.iterate(move_dx(direction))
    |> Enum.take(n + 1)
    |> Enum.reduce({rope, map}, fn
      h_xy, {[_ | rtail], map} ->
        rev_rope = move_rope([h_xy | rtail])
        map = map |> Map.put(hd(rev_rope), true)
        {rev_rope |> Enum.reverse(), map}
    end)
  end

  # Move the rope's head & all knots below recursively
  defp move_rope(rope, result \\ [])
  defp move_rope([t], result), do: [t | result]

  defp move_rope([head_xy | [n_xy | rtail]], result) do
    n_xy = move_tail(head_xy, n_xy)
    move_rope([n_xy | rtail], [head_xy | result])
  end

  defp move_tail({hx, hy}, {tx, ty}) do
    case {hx - tx, hy - ty} do
      {dx, dy} when abs(dx) <= 1 and abs(dy) <= 1 ->
        {tx, ty}

      {dx, dy} ->
        {dx, dy} = {min(max(dx, -1), 1), min(max(dy, -1), 1)}
        {tx + dx, ty + dy}
    end
  end

  defp run_course({moves, rope}) do
    moves
    |> Enum.reduce({rope, %{}}, &do_move/2)
    |> elem(1)
    |> Enum.count()
  end
end
