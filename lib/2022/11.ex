import AOC

aoc 2022, 11 do
  def p1(i), do: parse(i) |> run_rounds(20, &worry_less/1)
  def p2(i), do: parse(i) |> run_rounds(10000, &keep_worrying/1)

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(&parse_monkey/1)
    |> Map.new()
  end

  defp parse_monkey([header | tail]) do
    id =
      ~r/Monkey (\d+):/
      |> Regex.run(header)
      |> Enum.at(1)
      |> String.to_integer()

    [next | tail] = tail

    items =
      ~r/\s+Starting items: (\d.*)/
      |> Regex.run(next, capture: :all_but_first)
      |> then(&parse_items/1)

    [next | tail] = tail

    op =
      ~r/\s+Operation: new = (\w+) (.) (\w+)/
      |> Regex.run(next, capture: :all_but_first)
      |> then(&parse_op/1)

    [next | tail] = tail

    test =
      ~r/\s+Test: divisible by (\d+)/
      |> Regex.run(next, capture: :all_but_first)
      |> then(fn [n] -> String.to_integer(n) end)

    [next | tail] = tail

    mtrue =
      ~r/\s+If true: throw to monkey (\d+)/
      |> Regex.run(next, capture: :all_but_first)
      |> then(fn [n] -> String.to_integer(n) end)

    [next] = tail

    mfalse =
      ~r/\s+If false: throw to monkey (\d+)/
      |> Regex.run(next, capture: :all_but_first)
      |> then(fn [n] -> String.to_integer(n) end)

    {id, {items, op, {test, mtrue, mfalse}, 0}}
  end

  defp parse_items([str]),
    do: str |> String.split(", ") |> Enum.map(&String.to_integer/1)

  defp parse_op([x, op, y]) do
    {x, op, y}
  end

  # worry functions
  defp worry_less(x), do: div(x, 3)
  defp keep_worrying(x), do: x

  # Process monkeys
  defp process_monkey(id, map, worry_fn, factors) do
    case Map.get(map, id) do
      {[], _, _, _} ->
        map

      {[item | tail], op, test, n} ->
        # update our monkey, removing item
        monkey = {tail, op, test, n + 1}
        map = Map.put(map, id, monkey)
        # process one item
        item = operate(item, op)
        # worry division
        item = worry_fn.(item) |> Integer.mod(factors)
        # test
        {test_div, mtrue, mfalse} = test
        other_monkey = if Integer.mod(item, test_div) == 0, do: mtrue, else: mfalse
        map = map |> throw_to(other_monkey, item)
        # _ = IO.inspect(map, charlists: :as_lists)
        process_monkey(id, map, worry_fn, factors)
    end
  end

  defp throw_to(map, id, item) do
    # _ = IO.puts("Throw item #{item} to monkey #{id}")
    # get other monkey, update items
    {items, op, test, n} = Map.get(map, id)
    Map.put(map, id, {items ++ [item], op, test, n})
  end

  defp operate(old, {"old", op, val}) do
    val = if val == "old", do: old, else: String.to_integer(val)

    case op do
      "+" -> old + val
      "-" -> old - val
      "*" -> old * val
      "/" -> old / val
    end
  end

  defp run_round(map, worry_fn, factors) do
    map
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(map, &process_monkey(&1, &2, worry_fn, factors))
  end

  defp run_rounds(map, n, worry_fn) do
    factors = Map.values(map) |> Enum.map(fn {_, _, {t, _, _}, _} -> t end) |> Enum.product()

    1..n
    |> Enum.reduce(map, fn _, m -> run_round(m, worry_fn, factors) end)
    |> Enum.map(fn {_k, {_, _, _, n}} -> n end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end
end
