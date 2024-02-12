import AOC

aoc 2023, 4 do
  def p1(input), do: parse(input) |> grade_cards() |> score1()
  def p2(input), do: parse(input) |> grade_cards() |> more_cards()

  def parse(input) do
    # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(":", trim: true)
    |> Enum.at(1)
    |> String.split("|", trim: true)
    |> Enum.map(&parse_num_list/1)
  end

  def parse_num_list(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def grade_cards(list) do
    list
    |> Enum.map(fn l -> l |> Enum.map(&MapSet.new/1) end)
    |> Enum.map(fn [win, card] ->
      MapSet.intersection(win, card) |> MapSet.to_list() |> length()
    end)
  end

  def score1(list) do
    list
    |> Enum.map(fn
      0 -> 0
      1 -> 1
      n -> Integer.pow(2, n - 1)
    end)
    |> Enum.sum()
  end

  def more_cards(list) do
    list
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.reduce(Map.new(), fn
      {n, idx}, map ->
        count = add_cards(map, idx, n)
        map |> Map.put(idx, count)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def add_cards(_, _, 0), do: 1

  def add_cards(map, idx, n) when n > 0 do
    count = map |> Map.get(idx + n)
    count + add_cards(map, idx, n - 1)
  end
end
