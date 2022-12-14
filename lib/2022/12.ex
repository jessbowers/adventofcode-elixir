import AOC

aoc 2022, 12 do
  import Helpers.PriorityQueueHelper

  def p1(i), do: parse(i) |> find_source() |> find_shortest_path()
  def p2(i), do: parse(i) |> find_source() |> find_shortest_path_of_all()

  # parse a line into {x,y, val}
  defp parse_line_xy({line, y}) do
    line
    |> String.to_charlist()
    |> Enum.with_index(fn i, x -> {{x, y}, i} end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_line_xy/1)
    |> List.flatten()
    |> Map.new()
  end

  # return adjacent cells in map as list of {xy, val}
  defp adjacents_to(map, {x, y}) do
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
    |> Enum.map(fn {dx, dy} -> {dx + x, dy + y} end)
    |> Enum.map(fn k -> {k, Map.get(map, k, nil)} end)
    |> Enum.filter(&elem(&1, 1))
  end

  # Uniform Cost Search
  # Algo based on Dijkstra priority queue optimization https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Practical_optimizations_and_infinite_graphs
  # case: target found
  defp uniform_cost_search({{cost, curr_xy}, _frontier}, target, _explored, _map)
       when curr_xy == target,
       do: cost

  # case: failure, PriorityQueue / frontier is empty
  defp uniform_cost_search({{_, nil}, _frontier}, _target, _explored, _map), do: nil

  # normal case, next cheapest node in frontier is curr
  defp uniform_cost_search({{cost, curr_xy}, frontier}, target, explored, map) do
    # add curr node to the explored set
    explored = explored |> MapSet.put(curr_xy)
    curr_val = Map.get(map, curr_xy, nil)
    # cost is just number of steps, so add one
    curr_cost = cost + 1

    # update the frontier, looking at the neighbors
    frontier =
      map
      # get list of neighbors that are not explored
      |> adjacents_to(curr_xy)
      # reject if it's already explored
      |> Enum.reject(&MapSet.member?(explored, elem(&1, 0)))
      # reject if the height is to much
      |> Enum.reject(&(elem(&1, 1) > curr_val + 1))
      # insert these xy into the Priority Queue if the cost is < existing
      # or if the xy doesn't already exist in the queue (upsert_if)
      |> Enum.reduce(frontier, fn {xy, _}, pq -> pq |> upsert_if(curr_cost, xy, &(&1 < &2)) end)

    # explore the next closest node
    uniform_cost_search(PriorityQueue.pop(frontier), target, explored, map)
  end

  defp find_source(map) do
    {source, _} = Enum.find(map, &(elem(&1, 1) == ?S))
    map = map |> Map.put(source, ?a)
    {map, source}
  end

  defp find_shortest_path({map, source}) do
    # target is the letter E, which will have the height z
    {target, _} = Enum.find(map, &(elem(&1, 1) == ?E))
    map = map |> Map.put(target, ?z)
    # unexplored x,y
    frontier = PriorityQueue.new()
    # x,y we've already covered in the path
    explored = MapSet.new()
    # search for path with lowest cost
    uniform_cost_search({{0, source}, frontier}, target, explored, map)
  end

  defp find_shortest_path_of_all({map, _}) do
    map
    # find all possible starting points
    |> Enum.filter(&(elem(&1, 1) == ?a))
    # take just the xy
    |> Enum.map(&elem(&1, 0))
    # for every xy, shortest path or nil
    |> Enum.map(&find_shortest_path({map, &1}))
    # remove nils
    |> Enum.filter(& &1)
    # just return shortest of all
    |> Enum.sort(:asc)
    |> Enum.at(0)
  end
end
