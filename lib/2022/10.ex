import AOC

aoc 2022, 10 do
  def p1(i), do: parse(i) |> run() |> measure([20, 60, 100, 140, 180, 220])
  def p2(i), do: parse(i) |> run() |> draw_pixels()

  defp parse_line("noop"), do: {:noop, 1}

  defp parse_line(str) do
    str
    |> String.split(" ")
    |> Enum.at(1)
    |> String.to_integer()
    |> then(&{:add, 2, &1})
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp run_one(instr, [reg | tail]) do
    case instr do
      {:add, _t, val} -> [reg + val, reg, reg] ++ tail
      {:noop, _t} -> [reg, reg] ++ tail
    end
  end

  defp run(instructions) do
    instructions
    |> Enum.reduce([1], &run_one/2)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {r, i} -> {i, {r, r * i}} end)
    |> Map.new()
  end

  defp measure(runs, checks) do
    checks
    |> Enum.map(fn i -> runs |> Map.get(i, {0, 0}) |> elem(1) end)
    |> Enum.sum()
  end

  defp draw_pixels(runs) do
    1..240
    |> Enum.with_index()
    |> Enum.map(fn {k, i} ->
      sprite_x = runs |> Map.get(k, nil) |> elem(0)
      pos = Integer.mod(i, 40)
      if abs(sprite_x - pos) <= 1, do: "#", else: "."
    end)
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.puts/1)
  end
end
