import AOC

aoc 2023, 5 do
  def p1(input), do: parse(input) |> calc_locations() |> Enum.min()
  def p2(input), do: parse(input) |> search_seeds_by_range() |> elem(1)

  def parse(input) do
    [seeds | maps] = input |> String.split("\n\n")
    {seeds |> parse_seeds(), maps |> Enum.map(&parse_maps/1)}
  end

  def parse_seeds(i),
    do: i |> String.split(" ", trim: true) |> Enum.drop(1) |> Enum.map(&String.to_integer/1)

  def parse_maps(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&parse_map_line/1)
  end

  def parse_map_line(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  # format a map line to {src-x1, src-x2}, d
  def format_src([dest, src, n]), do: {{src, src + n}, dest - src}

  def calc_locations({seeds, maps}) do
    src_maps = maps |> Enum.map(fn m -> m |> Enum.map(&format_src/1) end)
    seeds |> Enum.map(&follow_map(&1, src_maps))
  end

  # filter function for finding map range for value
  def in_range(val), do: fn {{x1, x2}, _} -> val >= x1 && val < x2 end

  # Follow the map for a given seed value
  def follow_map(val, [smap | tl]) do
    {_, delta} = smap |> Enum.find({{0, 0}, 0}, in_range(val))
    follow_map(val + delta, tl)
  end

  # end of maps
  def follow_map(val, []), do: val

  ################ part 2

  # format a map line for part 2
  # {{src, src + n}, {dest, dest + n}, dest - src}
  def format_dest([dest, src, n]), do: %{loc: dest, delta: src - dest, len: n, skew: 0}

  def start_x(%{loc: loc}), do: loc
  def end_x(%{loc: loc, len: n}), do: loc + n
  def len_x(%{len: n}), do: n

  # shift to next level
  def shift(%{loc: loc, delta: d} = node, %{skew: s}),
    do: %{node | loc: loc + d, delta: 0, skew: s + d}

  # returns parts of node that exist before, inside, after target
  def trisect(node, target) do
    {ns, ne, nn} = {start_x(node), end_x(node), len_x(node)}
    {ts, te, _tn} = {start_x(target), end_x(target), len_x(target)}

    lower = %{node | loc: ns, len: min(nn, ts - ns)}
    mid = %{node | loc: max(ts, ns), len: min(te, ne) - max(ts, ns)}
    high = %{node | loc: te, len: ne - te}

    [lower, mid, high]
    |> Enum.map(fn
      %{len: n} when n <= 0 -> nil
      node -> node
    end)
  end

  # # sort fn for shortest final dest (x)
  # def shortest_path_cmp(p1, p2), do: Enum.at(p1, 0) < Enum.at(p2, 0)

  def format_seeds(seeds),
    do:
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [x, n] -> %{loc: x, len: n} end)
      |> Enum.sort(&(start_x(&1) < start_x(&2)))

  # convert maps to dest-oriented, reverse order list
  def format_rev_map_list(maps) do
    maps
    |> Enum.map(fn m -> m |> Enum.map(&format_dest/1) end)
    |> Enum.reverse()
    # for a given map section, sort by lowest start
    |> Enum.map(fn m -> m |> Enum.sort(&(start_x(&1) < start_x(&2))) end)
  end

  # Search for seed values within ranges of seeds
  def search_seeds_by_range({seeds, maps}) do
    maps = maps |> format_rev_map_list()
    # add a big & small across all ints
    [%{loc: -0xFFFFFFFFFFFFFFFF, len: 2 * 0xFFFFFFFFFFFFFFFF, delta: 0, skew: 0}]
    |> find_lowest_path(maps, format_seeds(seeds))
  end

  # for a given level, try each mapping to see if there is a solve in reverse
  def find_lowest_path([node | node_tl], [level | levels_tl], seeds) do
    # given a node, find intersections within a list of targets on a level
    result =
      node
      |> intersections(level)
      # then look for lowest path at the next level
      |> find_lowest_path(levels_tl, seeds)

    case result do
      {:ok, _} ->
        result

      {:fail} ->
        # go again on next node, same level
        find_lowest_path(node_tl, [level | levels_tl], seeds)
    end
  end

  def find_lowest_path([], _, _), do: {:fail}

  def find_lowest_path([node | ntl], [], seeds) do
    case find_target_seed(node, seeds) do
      {:ok, target} -> {:ok, target}
      {:fail} -> find_lowest_path(ntl, [], seeds)
    end
  end

  def find_target_seed(node, [seed | tl]) do
    case trisect(seed, node) do
      [_, nil, nil] ->
        # look in next seed
        find_target_seed(node, tl)

      [nil, nil, _] ->
        # node is below all seeds
        {:fail}

      [_, target, _] ->
        %{skew: s} = node
        {:ok, start_x(target) - s}
    end
  end

  def find_target_seed(_, []), do: {:fail}

  # find all intersecting target ranges for a given list of targets at this level
  def intersections(node, [target | tl]) do
    with {:t, [_, nxt, _]} when nxt != nil <- {:t, trisect(target, node)},
         {:s, [n1, n2, n3]} <- {:s, trisect(node, nxt)},
         {:s, [nil, n2, nil]} <- {:s, [n1, shift(nxt, n2), n3]} do
      [n2]
    else
      {:t, [_, nil, nil]} -> intersections(node, tl)
      {:t, [nil, nil, _]} -> [node]
      {:s, [n1, n2, nil]} -> [n1, n2]
      {:s, [nil, n2, n3]} -> [n2 | intersections(n3, tl)]
      {:s, [n1, n2, n3]} -> [n1 | [n2 | intersections(n3, tl)]]
    end
  end

  # no targets? just use node as-is
  def intersections(node, []), do: [node]
end
