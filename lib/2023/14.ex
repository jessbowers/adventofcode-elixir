alias AdventOfCode.Helpers.Transformers
alias AdventOfCode.Algorithms.Grid
import AOC

aoc 2023, 14 do
  def p1(i), do: parse(i) |> shift_north() |> score2()
  def p2(i), do: parse(i) |> do_shift_cycles(1_000_000_000) |> score2()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(&String.graphemes/1)
  end

  # first item in a range
  def range_first(range), do: range |> Range.to_list() |> hd()

  # slide the pebbles to a direction
  def slide_pebbles(map, blk, {x, y}, x_inc, blk_inc, blk_key) do
    case Map.get(map, {x, y}, ".") do
      "#" ->
        # increment the blk to the next x value
        {map, x_inc}

      "O" ->
        # move the O from x,y to the new location at blk
        map = map |> Map.pop!({x, y}) |> elem(1) |> Map.put(blk_key, "O")
        {map, blk_inc}

      _ ->
        # ignore
        {map, blk}
    end
  end

  # Part 1

  def shift_north(lines) do
    map = lines |> Grid.grid2d()
    max_x = Enum.count(lines) - 1
    range = 0..max_x

    map =
      for y <- range, reduce: map do
        map ->
          for x <- range, reduce: {map, range_first(range)} do
            {map, blk} -> slide_pebbles(map, blk, {x, y}, x + 1, blk + 1, {blk, y})
          end
          |> elem(0)
      end

    {map, max_x}
  end

  # Part 2

  # shift pebbles in 4 dimensions
  def shift_dem(map, max) do
    # shift north
    range = 0..max

    map =
      for y <- range, reduce: map do
        map ->
          for x <- range, reduce: {map, range_first(range)} do
            {map, blk} -> slide_pebbles(map, blk, {x, y}, x + 1, blk + 1, {blk, y})
          end
          |> elem(0)
      end

    # shift west
    map =
      for x <- range, reduce: map do
        map ->
          for y <- range, reduce: {map, range_first(range)} do
            {map, blk} -> slide_pebbles(map, blk, {x, y}, y + 1, blk + 1, {x, blk})
          end
          |> elem(0)
      end

    # shift south
    range = max..0

    map =
      for y <- range, reduce: map do
        map ->
          for x <- range, reduce: {map, range_first(range)} do
            {map, blk} -> slide_pebbles(map, blk, {x, y}, x - 1, blk - 1, {blk, y})
          end
          |> elem(0)
      end

    # shift east
    map =
      for x <- range, reduce: map do
        map ->
          for y <- range, reduce: {map, range_first(range)} do
            {map, blk} -> slide_pebbles(map, blk, {x, y}, y - 1, blk - 1, {x, blk})
          end
          |> elem(0)
      end

    map
  end

  # cache, look for loops
  def shift_cycle_cached(map, _, _, 0), do: map

  def shift_cycle_cached(map, max, cache, idx) do
    case Map.get(cache, map) do
      # clean remainder when modulo loop to the # lines left
      start when rem(idx, start - idx) == 0 ->
        map

      _ ->
        res = shift_dem(map, max)
        shift_cycle_cached(res, max, Map.put(cache, map, idx), idx - 1)
    end
  end

  def do_shift_cycles(lines, num) do
    max_x = Enum.count(lines) - 1
    # max_y = Enum.count(Enum.at(lines, 0)) - 1
    # max_x == max_y!
    cache = Map.new()

    map =
      lines
      |> Grid.grid2d()
      |> Map.reject(&(elem(&1, 1) == "."))
      |> shift_cycle_cached(max_x, cache, num)

    {map, max_x}
  end

  def score2({map, max_x}) do
    map
    # |> print2()
    |> Enum.filter(&(elem(&1, 1) == "O"))
    |> Enum.map(fn {{x, _}, _} -> max_x - x + 1 end)
    |> Enum.sum()
  end

  # helper print functions

  def prnt(lines) do
    lines |> Enum.map(&Enum.join/1) |> Enum.join("\n") |> IO.puts()
  end

  def print2(map) do
    IO.puts("Printing Map")
    # IO.inspect(map)

    map
    |> Enum.group_by(fn {{x, _y}, _} -> x end)
    |> Enum.sort()
    |> Enum.map(fn {_, list} -> list |> Enum.sort() |> Enum.map(&elem(&1, 1)) |> Enum.join() end)
    |> Enum.join("\n")
    |> IO.puts()

    map
  end
end
