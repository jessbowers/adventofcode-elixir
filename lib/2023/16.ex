alias AdventOfCode.Helpers.Transformers
alias AdventOfCode.Algorithms.Grid
import AOC

aoc 2023, 16 do
  def p1(input), do: parse(input) |> bounce_light({{0, 0}, :right})
  def p2(input), do: parse(input) |> bounce_all()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(fn l -> l |> String.graphemes() end)
    |> Grid.grid2d()
  end

  def next_pos({x, y}, direction) do
    xy =
      case direction do
        :right -> {x, y + 1}
        :left -> {x, y - 1}
        :up -> {x - 1, y}
        :down -> {x + 1, y}
      end

    {xy, direction}
  end

  def dir_char(direction) do
    case direction do
      :right -> ">"
      :left -> "<"
      :up -> "^"
      :down -> "v"
    end
  end

  def next_dir("-", dir) when dir in [:up, :down], do: [:left, :right]
  def next_dir("|", dir) when dir in [:left, :right], do: [:up, :down]
  def next_dir("/", :left), do: [:down]
  def next_dir("/", :right), do: [:up]
  def next_dir("/", :up), do: [:right]
  def next_dir("/", :down), do: [:left]
  def next_dir("\\", :right), do: [:down]
  def next_dir("\\", :left), do: [:up]
  def next_dir("\\", :down), do: [:right]
  def next_dir("\\", :up), do: [:left]
  def next_dir(_, dir), do: [dir]

  def shone_before(hist, pos_dir) do
    if hist |> MapSet.member?(pos_dir),
      do: {:node, nil},
      else: {:new_ground, MapSet.put(hist, pos_dir)}
  end

  # shine on to next position, moving in direction
  def shine({hist, map}, {pos, direction}) do
    # verify that we have a node here
    with {:node, val} when val != nil <- {:node, map |> Map.get(pos)},
         # verify that the node isn't shone before
         {:new_ground, hist} <- shone_before(hist, {pos, direction}) do
      # map = if val == ".", do: Map.put(map, pos, dir_char(direction)), else: map

      # check the value & direction to see where to shine next
      next_dir(val, direction)
      |> Enum.reduce({hist, map}, fn dir, hmap -> shine(hmap, next_pos(pos, dir)) end)
    else
      {:node, nil} -> {hist, map}
    end
  end

  def bounce_light(map, start) do
    hist_map = {MapSet.new(), map}
    {hist, _map} = shine(hist_map, start)
    hist |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.count()
  end

  def bounce_all(map) do
    max = map |> Enum.to_list() |> Enum.sort(:desc) |> hd() |> elem(0) |> elem(0)

    list = 0..max |> Enum.reduce([], fn x, acc -> [{{x, 0}, :right} | acc] end)
    list = 0..max |> Enum.reduce(list, fn x, acc -> [{{x, max}, :left} | acc] end)
    list = 0..max |> Enum.reduce(list, fn y, acc -> [{{0, y}, :down} | acc] end)
    list = 0..max |> Enum.reduce(list, fn y, acc -> [{{max, y}, :up} | acc] end)

    list |> Enum.map(fn pos -> bounce_light(map, pos) end) |> Enum.max()
  end


end
