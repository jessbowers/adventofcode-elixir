import AOC

aoc 2022, 7 do
  def p1(i), do: parse(i) |> dir_filter(small_filter(100_000)) |> Enum.sum()
  def p2(i), do: parse(i) |> find_delete(70_000_000, 30_000_000)

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> tree_from_lines()
    |> add_sizes()
  end

  # convert lines into symbols
  defp readline(["$", "cd", "/"]), do: {:cmd, :root}
  defp readline(["$", "cd", ".."]), do: {:cmd, :up}
  defp readline(["$", "cd", dir]), do: {:cmd, {:cd, dir}}
  defp readline(["$", "ls"]), do: {:cmd, :ls}
  defp readline(["dir", dir]), do: {:output, {:dir, dir}}
  defp readline([size, name]), do: {:output, {:file, name, String.to_integer(size)}}

  defp tree_from_lines(lines) do
    lines
    |> Enum.map(&readline/1)
    |> create_tree({:root, %{}})
  end

  defp create_tree([], {:root, curr}), do: curr
  defp create_tree([], ctx), do: do_command(:root, [], ctx)
  defp create_tree([{:cmd, cmd} | tail], ctx), do: do_command(cmd, tail, ctx)

  defp do_command(:root, tail, {:root, curr}), do: create_tree(tail, {:root, curr})
  defp do_command(:root, tail, ctx), do: do_command(:root, tail, move_up(ctx))
  defp do_command(:up, tail, ctx), do: create_tree(tail, move_up(ctx))
  defp do_command({:cd, dir}, tail, ctx), do: create_tree(tail, move_down(ctx, dir))
  defp do_command(:ls, tail, ctx), do: read_listing(tail, ctx)

  defp move_up({{grand, parent}, child}) do
    children = parent |> Map.get(:children) |> Map.put(child[:name], child)
    parent = parent |> Map.put(:children, children)
    {grand, parent}
  end

  defp move_down({parent, curr}, name) do
    child = curr |> Map.get(:children) |> Map.get(name) |> Map.put(:name, name)
    {{parent, curr}, child}
  end

  defp read_listing([{:output, fitem} | tail], {parent, curr}) do
    case fitem do
      {:dir, name} ->
        children = curr |> Map.get(:children, %{}) |> Map.put_new(name, %{})
        curr = curr |> Map.put(:children, children)
        read_listing(tail, {parent, curr})

      file ->
        files = [file | curr |> Map.get(:files, [])]
        curr = curr |> Map.put(:files, files)
        read_listing(tail, {parent, curr})
    end
  end

  defp read_listing(lines, ctx), do: create_tree(lines, ctx)

  # Decorate the tree with sizes for every node

  defp file_sizes(files),
    do: files |> Enum.map(fn {_, _, s} -> s end) |> Enum.sum()

  defp child_sizes(children),
    do: children |> Enum.map(&Map.get(elem(&1, 1), :size, 0)) |> Enum.sum()

  defp add_sizes_to(nil), do: :pop

  defp add_sizes_to(children) do
    {children, children |> Enum.map(&{elem(&1, 0), add_sizes(elem(&1, 1))})}
  end

  defp add_sizes(curr) do
    {_, curr} = curr |> Map.get_and_update(:children, &add_sizes_to/1)

    # combine file sizes and child sizes
    csizes = curr |> Map.get(:children, %{}) |> child_sizes()
    fsizes = curr |> Map.get(:files, []) |> file_sizes()

    curr |> Map.put(:size, fsizes + csizes)
  end

  # filter nodes based on size

  defp small_filter(val), do: fn size -> size < val end
  defp large_filter(val), do: fn size -> size > val end

  defp dir_filter(curr, filter_by) do
    child_sizes =
      curr
      |> Map.get(:children, %{})
      |> Enum.map(fn {_k, v} -> dir_filter(v, filter_by) end)
      |> List.flatten()

    cond do
      filter_by.(curr[:size]) -> [curr[:size] | child_sizes]
      true -> child_sizes
    end
  end

  defp find_delete(node, drive_max, update_size) do
    space_needed = node[:size] - (drive_max - update_size)
    node |> dir_filter(large_filter(space_needed)) |> Enum.sort(:asc) |> hd()
  end
end
