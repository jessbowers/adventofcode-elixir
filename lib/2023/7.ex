import AOC
alias AdventOfCode.Helpers.Transformers

aoc 2023, 7 do
  def p1(input), do: parse(input, &card_rank/1) |> rank_hands() |> score()
  def p2(input), do: parse(input, &card_rank_j/1) |> rank_hands() |> score()

  def parse(input, rank_fn) do
    input
    |> Transformers.lines()
    |> Enum.map(&Transformers.words/1)
    |> Enum.map(&parse_hand(&1, rank_fn))
  end

  def parse_hand([cards, bid], rank_fn) do
    cards = cards |> String.graphemes() |> Enum.map(&rank_fn.(&1))
    bid = bid |> String.to_integer()
    {cards, bid}
  end

  def card_rank(c) do
    case c do
      "T" -> 10
      "J" -> 11
      "Q" -> 12
      "K" -> 13
      "A" -> 14
      _ -> c |> String.to_integer()
    end
  end

  def card_rank_j(card) do
    card
    |> card_rank()
    |> then(fn
      11 -> 0
      c -> c
    end)
  end

  # Compare values of two hands of cards, looking at each card's mate individually
  def cmp_cards([], []), do: true

  def cmp_cards([c1 | c1_tl], [c2 | c2_tl]) do
    cond do
      c1 == c2 -> cmp_cards(c1_tl, c2_tl)
      true -> c1 < c2
    end
  end

  def sort_freq(freq), do: freq |> Map.to_list() |> Enum.sort(&(elem(&1, 1) > elem(&2, 1)))

  def replace_jokers(freq) do
    case freq |> Map.pop(0, nil) do
      {nil, _} ->
        freq

      {5, _} ->
        freq

      {jn, freq} ->
        highest = freq |> sort_freq() |> Enum.at(0, {0, 0}) |> elem(0)
        {_, freq} = freq |> Map.get_and_update(highest, fn hn -> {hn, hn + jn} end)
        freq
    end
  end

  def rank_hand({cards, bid}) do
    counts = cards |> Enum.frequencies() |> replace_jokers() |> sort_freq()

    rank =
      case counts |> Enum.take(3) do
        [{_, 5}] -> 7
        [{_, 4}, _] -> 6
        [{_, 3}, {_, 2}] -> 5
        [{_, 3}, _, _] -> 4
        [{_, 2}, {_, 2}, _] -> 3
        [{_, 2}, _, _] -> 2
        _ -> 1
      end

    %{cards: cards, bid: bid, rank: rank}
  end

  def rank_hands(hands),
    do:
      hands
      |> Enum.map(&rank_hand/1)
      |> Enum.sort(fn %{rank: r1, cards: c1}, %{rank: r2, cards: c2} ->
        # compare ranks, but if equal, compare cards
        r1 < r2 || (r1 == r2 && cmp_cards(c1, c2))
      end)

  def score(hands),
    do:
      hands
      |> Enum.with_index()
      |> Enum.map(fn {%{bid: bid}, i} -> bid * (i + 1) end)
      |> Enum.sum()
end
