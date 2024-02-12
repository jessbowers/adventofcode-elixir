import AOC

aoc 2023, 2 do
  def p1(input),
    do: parse(input) |> filter(%{"red" => 12, "green" => 13, "blue" => 14}) |> grade()

  def p2(input),
    do: parse(input) |> power()

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    ~r/Game (\d+): (.*)/
    |> Regex.run(line, capture: :all_but_first)
    |> parse_moves()
  end

  def parse_moves([id, line]) do
    moves =
      line
      |> String.split("; ")
      |> Enum.map(fn group ->
        group
        |> String.split(", ")
        |> Enum.map(&parse_move/1)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn {color, n}, acc ->
        acc
        |> Map.get_and_update(color, fn curr ->
          if curr != nil && curr > n do
            {curr, curr}
          else
            {curr, n}
          end
        end)
        |> elem(1)
      end)

    {String.to_integer(id), moves}
  end

  def parse_move(line) do
    move = ~r/(\d+) (\w+)/ |> Regex.run(line, capture: :all_but_first)
    color = move |> Enum.at(1)
    num = move |> Enum.at(0) |> String.to_integer()
    {color, num}
  end

  def filter(games, maxes) do
    games
    |> Enum.filter(fn {_, game} ->
      game |> Enum.all?(fn {k, n} -> n <= Map.get(maxes, k, 0) end)
    end)
  end

  def grade(games) do
    games
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.sum()
  end

  def power(games) do
    games
    |> Enum.map(fn {_, moves} ->
      moves |> Enum.map(&elem(&1, 1)) |> Enum.product()
    end)
    |> Enum.sum()
  end
end
