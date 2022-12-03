import AOC

aoc 2022, 2 do
  def p1(input), do: parse_games(input) |> play_strategy()
  def p2(input), do: parse_games(input) |> play_outcomes()

  defp parse_game(s),
    do: s |> String.split(" ", trim: true) |> Enum.map(&String.to_atom/1) |> List.to_tuple()

  defp parse_games(s), do: s |> String.split("\n", trim: true) |> Enum.map(&parse_game/1)

  # decode the ABC to RPC
  defp decode_elf_moves({elf, me}) do
    case elf do
      :A -> {:Rock, me}
      :B -> {:Paper, me}
      :C -> {:Scissors, me}
    end
  end

  defp decode_my_moves({elf, me}) do
    case me do
      :X -> {elf, :Rock}
      :Y -> {elf, :Paper}
      :Z -> {elf, :Scissors}
    end
  end

  defp values_for_mine({elf, me}) do
    case me do
      :Rock -> {elf, me, 1}
      :Paper -> {elf, me, 2}
      :Scissors -> {elf, me, 3}
    end
  end

  # draw
  defp play_round({elf, me, val}) when elf == me, do: {{elf, me, val}, 3}

  defp play_round({elf, me, val}) do
    case {elf, me} do
      {:Rock, :Paper} -> {{elf, me, val}, 6}
      {:Rock, :Scissors} -> {{elf, me, val}, 0}
      {:Paper, :Rock} -> {{elf, me, val}, 0}
      {:Paper, :Scissors} -> {{elf, me, val}, 6}
      {:Scissors, :Rock} -> {{elf, me, val}, 6}
      {:Scissors, :Paper} -> {{elf, me, val}, 0}
    end
  end

  defp score_round({{_e, _m, val}, n}), do: val + n

  defp play_strategy(games) do
    games
    |> Enum.map(&decode_elf_moves/1)
    |> Enum.map(&decode_my_moves/1)
    |> Enum.map(&values_for_mine/1)
    |> Enum.map(&play_round/1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end

  #  X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win. Good luck!"
  defp decode_outcomes({elf, out}) do
    case {elf, out} do
      {_, :Y} -> {elf, elf}
      {:Rock, :X} -> {elf, :Scissors}
      {:Rock, :Z} -> {elf, :Paper}
      {:Paper, :X} -> {elf, :Rock}
      {:Paper, :Z} -> {elf, :Scissors}
      {:Scissors, :X} -> {elf, :Paper}
      {:Scissors, :Z} -> {elf, :Rock}
    end
  end

  defp play_outcomes(games) do
    games
    |> Enum.map(&decode_elf_moves/1)
    |> Enum.map(&decode_outcomes/1)
    |> Enum.map(&values_for_mine/1)
    |> Enum.map(&play_round/1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end
end
