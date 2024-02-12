import AOC

aoc 2023, 15 do
  def p1(input), do: parse(input) |> hash_all() |> Enum.sum()
  def p2(input), do: parse(input)

  def parse(input), do: input |> String.split(",", trim: true) |> Enum.map(&String.to_charlist/1)

  # hashing
  def hash(chars, acc \\ 0)
  def hash([], acc), do: acc
  def hash([c | tl], acc), do: hash(tl, rem((acc + c) * 17, 256))

  def hash_all(list), do: list |> Enum.map(&hash/1)
end
