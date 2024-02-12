import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 1 do
  def p1(input), do: parse_with_digits(input) |> calibrate()
  def p2(input), do: parse_all_nums(input) |> calibrate()

  def parse_with_digits(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&filter_nums/1)
  end

  def filter_nums(charlist) do
    charlist
    |> Enum.filter(fn x -> x >= ?0 && x <= ?9 end)
    |> Enum.map(fn x -> x - ?0 end)
    |> Enum.to_list()
  end

  def calibrate(list) do
    list
    |> Enum.map(fn nn ->
      List.first(nn) * 10 + List.last(nn)
    end)
    |> Enum.sum()
  end

  # -- part 2

  def replace_txt_nums(text) do
    text
    |> String.replace("one", "1")
    |> String.replace("two", "2")
    |> String.replace("three", "3")
    |> String.replace("four", "4")
    |> String.replace("five", "5")
    |> String.replace("six", "6")
    |> String.replace("seven", "7")
    |> String.replace("eight", "8")
    |> String.replace("nine", "9")
  end

  # convert by reading one char at a time
  def convert_text_nums(buffer, [c | tl]) do
    (buffer <> c)
    |> replace_txt_nums()
    |> convert_text_nums(tl)
  end

  def convert_text_nums(line, []), do: line

  def parse_text_nums(line) do
    ~r/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/
    |> Regex.scan(line)
    |> Enum.map(&List.last/1)
    |> Enum.map(&replace_txt_nums/1)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_all_nums(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&parse_text_nums/1)
  end
end
