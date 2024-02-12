import AOC
alias AdventOfCode.Helpers.Transformers
alias AdventOfCode.Algorithms.Arithmetics

aoc 2023, 6 do
  def p1(input), do: parse(input) |> run_races()
  def p2(input), do: parse2(input) |> run_one_race()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&(String.split(&1, ":") |> Enum.at(1)))
    |> Enum.map(&Transformers.int_words/1)
    |> Enum.zip()
  end

  def run_races(races) do
    races
    |> Enum.map(fn {limit, record} ->
      1..limit
      |> Enum.map(fn x -> (limit - x) * x end)
      |> Enum.filter(&(&1 > record))
      |> Enum.count()
    end)
    |> Enum.product()
  end

  def parse2(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&parse_combo_line/1)
  end

  def parse_combo_line(line) do
    line
    |> String.split(":")
    |> Enum.at(1)
    |> String.to_charlist()
    |> Enum.filter(fn c -> c >= ?0 && c <= ?9 end)
    |> Enum.reduce(0, fn i, a -> a * 10 + i - ?0 end)
  end

  def run_one_race([limit, record]) do
    # solve using quadratic formula
    [a, b, c] = [1, -limit, record]

    {:ok, {x1, x2}} = Arithmetics.quadratic(a, b, c) |> IO.inspect()

    # calc how many integer times break the record
    floor(x1) - ceil(x2) + 1
  end

  def search(x, limit, record, incr) do
    case (limit - x) * x > record do
      true -> x
      false -> search(incr.(x), limit, record, incr)
    end
  end
end
