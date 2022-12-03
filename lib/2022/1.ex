import AOC

aoc 2022, 1 do
  def p1, do: parse() |> biggest_elf()
  def p2, do: parse() |> top_three_elves()

  defp parse_elf(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(0, &(&1 + &2))
  end

  defp parse() do
    input_string()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_elf/1)
  end

  defp biggest_elf(elves) do
    elf = elves |> Enum.sort(:desc) |> Enum.at(0)
    IO.puts("biggest: #{inspect(elf)}")
  end

  defp top_three_elves(elves) do
    elves
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(0, &(&1 + &2))
    |> IO.puts()
  end
end
