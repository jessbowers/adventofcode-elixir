import AOC
alias AdventOfCode.Algorithms.Grid
require IEx

aoc 2023, 17 do
  def p1(input), do: parse(input) |> solve_shortest_path(1, 3)
  def p2(input), do: parse(input) |> solve_shortest_path(4, 10)

  def parse(input), do: input |> Grid.text_to_grid2d(&String.graphemes/1, &String.to_integer/1)

  # find maximum x,y
  def max_map(map),
    do: map |> Enum.to_list() |> Enum.sort(:desc) |> then(fn [{max_xy, _} | _] -> max_xy end)

  # move xy in a direction
  def move_xy({x, y}, dir, steps \\ 1) do
    case dir do
      :left -> {x, y - steps}
      :right -> {x, y + steps}
      :up -> {x - steps, y}
      :down -> {x + steps, y}
    end
  end

  # turn from this direction
  def turn(dir) do
    case dir do
      d when d in [:left, :right] -> [:up, :down]
      d when d in [:up, :down] -> [:left, :right]
      nil -> []
    end
  end

  # for a given xy, create an edge with # steps in this direction
  def create_edge(xy, dir, steps, map) do
    1..steps
    |> Enum.map(&move_xy(xy, dir, &1))
    |> Enum.map(&{&1, Map.get(map, &1)})
    |> Enum.reduce({{xy, dir, steps}, 0}, fn
      {_, nil}, _ -> nil
      {xy2, val}, {_, acc} -> {{xy, dir, steps, xy2}, acc + val}
    end)
  end

  # given a map & min/max number of steps, find all edges from each xy
  def all_edges(map, min, max) do
    # all xy
    edges =
      for {xy, _val} <- map |> Enum.to_list(),
          # min to max steps
          s <- min..max,
          # all directions
          d <- [:up, :down, :left, :right],
          reduce: [] do
        acc -> [create_edge(xy, d, s, map) | acc]
      end
      |> Enum.filter(& &1)

    edges
    |> Enum.map(fn {{from_xy, dir, steps, to_xy}, cost} ->
      {from_xy, {to_xy, dir, steps, cost}}
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  # A* huristic is manhattan distance to target
  def node_hcost(xy, cost, target_xy) do
    [{x1, y1}, {x2, y2}] = [xy, target_xy]
    dist = abs(x1 - x2) + abs(y1 - y2)
    cost + dist
  end

  # cache key
  def node_key({{x, y}, dir, steps}) do
    d = (dir |> Atom.to_charlist() |> hd()) - ?a
    x + y * 0x100 + d * 0x10000 + steps * 0x1000000
  end

  # Traverse the grid, looking for shortest path to target
  # success state
  def traverse({{cost, {xy, _, _}}, _pq}, %{target: target_xy}, _) when xy == target_xy,
    do: cost

  # keep going state
  def traverse({{_cost, {xy, dir, cost}}, pq}, journey, explored) do
    %{map: grid, target: target_xy} = journey

    next_dirs = turn(dir)

    adjacents =
      grid
      |> Map.get(xy)
      |> Enum.filter(fn {_xy, dir, _s, _val} -> dir in next_dirs end)
      # reformat and add cost
      |> Enum.map(fn {xy, dir, steps, val} -> {{xy, dir, steps}, val + cost} end)
      # reject explored nodes
      |> Enum.reject(fn {edge, _cost} -> MapSet.member?(explored, node_key(edge)) end)

    # put all these edges in explored
    explored =
      adjacents
      |> Enum.reduce(explored, fn {edge, _cost}, acc -> acc |> MapSet.put(node_key(edge)) end)

    # add them to the priority queue
    pq =
      adjacents
      |> Enum.reduce(pq, fn {edge, cost}, pq ->
        {xy, dir, _} = edge
        hcost = node_hcost(xy, cost, target_xy)
        pq |> PriorityQueue.put(hcost, {xy, dir, cost})
      end)

    traverse(PriorityQueue.pop(pq), journey, explored)
  end

  def solve_shortest_path(map, min, max) do
    # target is max xy
    target_xy = max_map(map)

    # create a graph of all possible edges (xy, dir, steps, cost) within min..max # of steps
    grid = map |> all_edges(min, max)

    # start at 0,0 moving right & down
    [start1, start2] = [{{0, 0}, :right, 0}, {{0, 0}, :down, 0}]

    # add both to the frontier
    frontier = PriorityQueue.new() |> PriorityQueue.put(0, start1) |> PriorityQueue.put(0, start2)

    # params used in every step
    journey = %{:map => grid, :target => target_xy, min: min, max: max}

    # solve using djykstra
    traverse(frontier |> PriorityQueue.pop(), journey, MapSet.new())
  end
end
