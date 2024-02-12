import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 13 do
  def p1(i), do: parse(i) |> mirrors(0)
  def p2(i), do: parse(i) |> mirrors(1)

  def parse(input) do
    input
    |> Transformers.sections()
    |> Enum.map(&parse_section/1)
    |> Enum.with_index()
  end

  def parse_section(section),
    do: section |> Transformers.lines() |> Enum.map(&String.to_charlist/1)

  # compare two lines
  # d is the maximum delta between the lines
  def cmp_lines(a, b, d) do
    diff_count =
      Enum.zip(a, b)
      |> Enum.reduce(0, fn
        {a, b}, acc when a == b -> acc
        _, acc -> acc + 1
      end)

    if diff_count <= d, do: {:ok, diff_count}, else: {:fail}
  end

  # Check the mirror effect at ai and bi in the line, recursing forward and
  # back at the same time
  # checking has fallen out of bounds, assume OK
  def check_mirror(a, b, idx, d, dc) when length(a) == 0 or length(b) == 0 do
    # but OK only if our delta count is exactly matching our d (delta max)
    if(dc == d, do: {:ok, idx}, else: {:fail})
  end

  # still matches, recurse to next line in front/back
  def check_mirror([a | atl], [b | btl], idx, d, dc) do
    case cmp_lines(a, b, d) do
      {:ok, n} when n + dc <= d -> check_mirror(atl, btl, idx, d, n + dc)
      _ -> {:fail}
    end
  end

  def front_back(line, bi) do
    # spit the lines at the edge, reverse the front lines
    line
    |> Enum.split(bi)
    |> Tuple.to_list()
    |> then(fn [front, back] -> [Enum.reverse(front), back] end)
    |> Enum.map(&Enum.drop(&1, 1))
  end

  # Find the edge of the mirror
  # potential mirror, check it
  def find_mirrors_edge([{a, _ai}, {b, bi} | tl], line, d) do
    with {:ok, dc} <- cmp_lines(a, b, d),
         [front, back] <- front_back(line, bi),
         {:ok, res} <- check_mirror(front, back, bi, d, dc) do
      {:ok, res}
    else
      {:fail} -> find_mirrors_edge([{b, bi} | tl], line, d)
    end
  end

  # end of the line, no mirror
  def find_mirrors_edge([_], _, _), do: {:fail}

  # find mirror in both dimensions
  def find_mirrors({section, sidx}, d) do
    with {:horiz, {:fail}} <-
           {:horiz, find_mirrors_edge(section |> Enum.with_index(), section, d)},
         {:vert, {:fail}} <-
           {:vert,
            section
            |> Transformers.transpose()
            |> then(&find_mirrors_edge(&1 |> Enum.with_index(), &1, d))} do
      # no mirror found, this should not be possible
      {:fail, sidx, section, section |> Transformers.transpose()}
    else
      {:horiz, {:ok, idx}} -> idx * 100
      {:vert, {:ok, idx}} -> idx
    end
  end

  # d is difference count, or number of items different in a match
  def mirrors(patterns, d) do
    patterns
    |> Enum.map(&find_mirrors(&1, d))
    |> Enum.sum()
  end
end
