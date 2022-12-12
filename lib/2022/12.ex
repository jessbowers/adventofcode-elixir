import AOC

aoc 2022, 12 do
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

  # return adjacent cells in map
  defp adjacents_to(map, {x, y}) do
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
    |> Enum.map(fn {dx, dy} -> {dx + x, dy + y} end)
    |> Enum.map(fn k -> {k, Map.get(map, k, nil)} end)
    |> Enum.filter(&elem(&1, 1))
  end

  defp member_of_queue?(queue, value) do
    queue
    |> PriorityQueue.to_list()
    |> Enum.filter(fn {_k, v} -> v == value end)
    |> then(fn
      # nothing returned from the filter
      [] -> {:missing}
      [{val, xy}] -> {xy, val}
      _ -> {:error}
    end)
  end

  # priority queue, finds the value in the queue, moves to a different key
  defp replace_in_queue(queue, value, key) do
    queue
    |> PriorityQueue.to_list()
    |> Enum.reject(&(elem(&1, 1) == value))
    |> Enum.reduce(PriorityQueue.new(), fn {k, v}, pq -> pq |> PriorityQueue.put(k, v) end)
    |> PriorityQueue.put(key, value)
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

      # add whether this value is in the frontier
      |> Enum.map(&{&1, member_of_queue?(frontier, elem(&1, 0))})
      |> Enum.reduce(frontier, fn
        # add those not in the frontier to it
        {{xy, _}, {:missing}}, acc ->
          acc |> PriorityQueue.put(curr_cost, xy)

        # replace any with cost values that are > current cost
        {{xy, _}, {_, cost}}, acc when curr_cost < cost ->
          acc |> replace_in_queue(xy, curr_cost)

        # default, cost is greater, etc
        _, acc ->
          acc
      end)

    # explore the next closest node
    uniform_cost_search(PriorityQueue.pop(frontier), target, explored, map)
  end

  defp find_source(map) do
    {source, _} = Enum.find(map, &(elem(&1, 1) == ?S))
    map = map |> Map.put(source, ?a)
    {map, source}
  end

  defp find_shortest_path({map, source}) do
    {target, _} = Enum.find(map, &(elem(&1, 1) == ?E))
    map = map |> Map.put(target, ?z)
    frontier = PriorityQueue.new()
    explored = MapSet.new()
    uniform_cost_search({{0, source}, frontier}, target, explored, map)
  end

  defp find_shortest_path_of_all({map, _}) do
    map
    |> Enum.filter(&(elem(&1, 1) == ?a))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&find_shortest_path({map, &1}))
    |> Enum.filter(& &1)
    |> Enum.sort(:asc)
    |> Enum.at(0)
  end
end
