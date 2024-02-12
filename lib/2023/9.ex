import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 9 do
  def p1(i), do: parse(i) |> read_sensors() |> calc_next_values()
  def p2(i), do: parse(i) |> read_sensors() |> calc_first_values()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&Transformers.int_words/1)
  end

  def read_sensors(list), do: list |> Enum.map(&read_sensor(&1, [], [&1]))

  def read_sensor([first | tl], acc, prev_lines) do
    case tl do
      [next | tl] ->
        read_sensor([next | tl], [next - first | acc], prev_lines)

      [] ->
        readings = acc |> Enum.reverse()

        case Enum.all?(readings, &(&1 == 0)) do
          true ->
            # done, return all reading lines
            [readings | prev_lines]

          false ->
            # go to next level
            read_sensor(readings, [], [readings | prev_lines])
        end
    end
  end

  def calc_next_values(list),
    do:
      list
      |> Enum.map(fn vs -> vs |> Enum.reverse() |> Enum.map(&Enum.reverse/1) end)
      |> predict_values(&+/2)

  def calc_first_values(list),
    # in this case do not reverse and predict values at the heads of the list, with a subtract fn
    do: list |> predict_values(&-/2)

  def predict_values(list, delta_fn),
    do:
      list
      |> Enum.map(fn values ->
        next = calc_next_value(values, 0, delta_fn)
        [next | values |> List.first()] |> Enum.reverse()
      end)
      |> Enum.map(&List.last/1)
      |> Enum.sum()

  def calc_next_value([[val | _vtl] | tl], prev, delta_fn),
    do: calc_next_value(tl, delta_fn.(val, prev), delta_fn)

  def calc_next_value([], prev, _), do: prev
end
