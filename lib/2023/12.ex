import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 12 do
  def p1(input), do: parse(input) |> search() |> Enum.sum()
  def p2(input), do: parse(input) |> expand() |> search() |> Enum.sum()

  def parse(input) do
    input
    |> Transformers.lines()
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> then(fn [l1, l2] -> {String.to_charlist(l1), Transformers.int_words(l2, ",")} end)
    end)
  end

  # seach on all lines
  def search(lines),
    do:
      lines
      |> Enum.map(fn {items, counts} -> cached_search(items, counts, Map.new()) |> elem(0) end)

  # is the group of items all broken?
  def is_broken(items, n), do: items |> Enum.take(n) |> Enum.all?(&(&1 != ?.))

  # is group of items all working?
  def is_good(items), do: Enum.all?(items, &(&1 != ?#))

  def expand(lines) do
    lines
    |> Enum.map(fn {list, groups} ->
      for _ <- 0..3, reduce: {list, groups} do
        {blist, bgroups} -> {Enum.concat(blist, [?? | list]), Enum.concat(bgroups, groups)}
      end
    end)
  end

  # return count of variations on this line
  # we are looking for non-working groups of items, groups should have sizes
  # matching those in the groups list
  def cached_search(list, groups, cache) do
    # check cache for match
    case Map.get(cache, {list, groups}) do
      nil ->
        {res, cache} = subsearch(list, groups, cache)
        {res, Map.put(cache, {list, groups}, res)}

      result ->
        {result, cache}
    end
  end

  # items ended exactly size of the line, success condition
  def subsearch([], [], cache), do: {1, cache}
  # more groups needed, but we have no more items, fail
  def subsearch([], _, cache), do: {0, cache}

  # no more groups needed, but more items avail
  # ok, but only if they're all good
  def subsearch(list, [], cache), do: if(is_good(list), do: {1, cache}, else: {0, cache})

  # good/working item at the head, skip it
  def subsearch([?. | list_tl], groups, cache), do: cached_search(list_tl, groups, cache)

  # unknown/damaged record, try both working / not working
  def subsearch([?? | list_tl], groups, cache) do
    # skip this position (assume .)
    {res1, cache} = cached_search(list_tl, groups, cache)
    # change this position to a specific #
    {res2, cache} = cached_search([?# | list_tl], groups, cache)
    # combine the results
    {res1 + res2, cache}
  end

  # not working, which is what we're looking for
  # test for conditions
  def subsearch([?# | list_tl] = list, [c | c_tl], cache) do
    # check length, check that entire group is #|?, check separator
    case {length(list), is_broken(list_tl, c - 1), Enum.at(list, c) != ?#} do
      # just right length, no sep needed, continue
      {len, true, _} when len == c -> cached_search([], c_tl, cache)
      # length good, group good, sep good, keep going to next group
      {len, true, true} when len > c -> cached_search(list_tl |> Enum.drop(c), c_tl, cache)
      # fail
      _ -> {0, cache}
    end
  end
end
