import AOC

aoc 2022, 9 do
  def p1(input), do: parse(input) |> run_course()

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

  defp move_dx(:U), do: fn {x, y} -> {x, y - 1} end
  defp move_dx(:D), do: fn {x, y} -> {x, y + 1} end
  defp move_dx(:L), do: fn {x, y} -> {x - 1, y} end
  defp move_dx(:R), do: fn {x, y} -> {x + 1, y} end

  defp do_move([], course), do: course

  defp do_move([{direction, n} | tail], {rope_h, rope_t, map}) do
    rope_h
    |> Stream.iterate(move_dx(direction))
    |> Enum.take(n + 1)
    |> Enum.reduce({rope_h, rope_t, map}, fn h_xy, {_, t_xy, map} ->
      t_xy = move_tail(t_xy, h_xy)
      {h_xy, t_xy, Map.put(map, t_xy, true)}
    end)
    |> then(&do_move(tail, &1))
  end

  defp move_tail({tx, ty}, {hx, hy}) do
    case {hx - tx, hy - ty} do
      {dx, dy} when abs(dx) <= 1 and abs(dy) <= 1 ->
        {tx, ty}

      {dx, dy} ->
        {dx, dy} = {min(max(dx, -1), 1), min(max(dy, -1), 1)}
        {tx + dx, ty + dy}
    end
  end

  defp run_course(moves) do
    start_xy = {0, 0}
    course = {start_xy, start_xy, %{start_xy => true}}

    do_move(moves, course)
    |> then(fn {_, _, m} -> m end)
    |> Enum.count()
  end
end
