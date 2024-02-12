import AOC
alias AdventOfCode.Algorithms.Grid

aoc 2023, 10 do
  def p1(input), do: parse(input) |> search() |> count()
  def p2(input), do: parse(input) |> search() |> measure_points()

  def parse(input), do: input |> Grid.text_to_grid2d()

  def outs(node) do
    case node do
      "|" -> [{-1, 0}, {1, 0}]
      "-" -> [{0, -1}, {0, 1}]
      "L" -> [{-1, 0}, {0, 1}]
      "J" -> [{-1, 0}, {0, -1}]
      "7" -> [{0, -1}, {1, 0}]
      "F" -> [{0, 1}, {1, 0}]
      "." -> []
      "S" -> [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    end
  end

  def letter_for_outs(curr_outs) do
    ~w/| - L J 7 F . S/
    |> Enum.find(fn n ->
      n |> outs() |> MapSet.new() == curr_outs |> MapSet.new()
    end)
  end

  def adjacents_to(map, {{x, y}, val}) do
    val
    |> outs()
    |> Enum.map(fn {dx, dy} -> {dx + x, dy + y} end)
    |> Enum.map(fn k -> {k, Map.get(map, k, ".")} end)
    |> Enum.filter(fn {_k, v} -> v != "." end)
    |> Enum.filter(fn {{x2, y2}, v} ->
      # other node connects back to us as well
      outs(v) |> Enum.any?(fn {dx, dy} -> {dx + x2, dy + y2} == {x, y} end)
    end)
  end

  def bf_search2(curr, grid, explored, target) do
    frontier =
      grid
      |> adjacents_to(curr)
      |> Enum.reject(&MapSet.member?(explored, &1))

    frontier
    |> Enum.map(fn
      node when node == target -> explored |> MapSet.put(node)
      node -> bf_search2(node, grid, explored |> MapSet.put(node), target)
    end)
    |> Enum.sort(fn a, b -> MapSet.size(a) > MapSet.size(b) end)
    |> List.first()
  end

  # find loop
  def search(grid) do
    start = grid |> Enum.find(&(elem(&1, 1) == "S"))
    # target is the to find a loop, but the longest distance from start
    {bf_search2(start, grid, MapSet.new(), start) |> Map.new(), grid}
  end

  # what is the longest path away from start
  def count({path, _}), do: path |> Enum.count() |> div(2)

  # replace the s with the right letter
  def replace_start(map) do
    {{sx, sy}, sv} = map |> Enum.find(&(elem(&1, 1) == "S"))

    # find the letter by building a list of the outs, finding the letter that matches
    letter =
      map
      |> adjacents_to({{sx, sy}, sv})
      |> Enum.map(fn {{x, y}, _} -> {x - sx, y - sy} end)
      |> then(&letter_for_outs/1)

    Map.put(map, {sx, sy}, letter)
  end

  # create a two dimensional array of rows & items in the row
  def expand_lines(map) do
    map
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.group_by(fn {{x, _}, _} -> x end, fn {{_x, y}, v} -> {y, v} end)
  end

  def edge_letters(), do: ~w/F L -/ |> MapSet.new()
  def fin_letters(), do: ~w/J 7/ |> MapSet.new()
  def is_edge(v), do: edge_letters() |> MapSet.member?(v)

  def is_fin(v, in_edge) do
    case in_edge do
      "F" -> v == "J"
      "L" -> v == "7"
      _ -> false
    end
  end

  # end states
  def convert_edges([], _), do: []
  def convert_edges([_ | []], _), do: []

  def convert_edges([{y, v} | [{next_y, _} | _] = tl], in_edge) do
    delta = next_y - y - 1

    cond do
      !in_edge && is_edge(v) ->
        # begin of a horizontal edge, record the value as in_edge
        # skipping the curr
        convert_edges(tl, v)

      in_edge && is_edge(v) ->
        # middle of horizontal edge, just skip
        convert_edges(tl, in_edge)

      in_edge && !is_edge(v) && is_fin(v, in_edge) ->
        # finalization of a horiz edge
        # treat a fin of an edge same as normal crossing of a |
        [delta | convert_edges(tl, false)]

      in_edge && !is_edge(v) && !is_fin(v, in_edge) ->
        # finalization of edge, but U shape or upside down U
        # treat a non-fin as a flip of even/odd by adding a spacer 0
        [0 | [delta | convert_edges(tl, false)]]

      true ->
        # not currently in an edge, normal case, eg |...|
        [delta | convert_edges(tl, false)]
    end
  end

  # measure points inside the loop
  # use ray casting to count points on every line
  def measure_points({path, _grid}) do
    path
    |> replace_start()
    |> expand_lines()
    |> Map.values()
    |> Enum.map(fn ln ->
      ln
      |> convert_edges(false)
      # even/odd rule for raycasting
      |> Enum.take_every(2)
    end)
    |> List.flatten()
    |> Enum.sum()
  end
end
