defmodule AdventOfCode.Algorithms.Arithmetics do
  @moduledoc """
  Algorithms related to arithmetics operations
  """
  @doc """
  Returns a list of divisors of a number.

  ## Example

    iex> Arithmetics.divisors(0)
    :error

    iex> Arithmetics.divisors(1)
    [1]

    iex> Arithmetics.divisors(12)
    [1, 12, 2, 6, 3, 4]

    iex> Arithmetics.divisors(13)
    [1, 13]

  """
  def divisors(0), do: :error

  def divisors(n) do
    1..trunc(:math.sqrt(n))
    |> Enum.flat_map(fn
      x when rem(n, x) != 0 -> []
      x when x != div(n, x) -> [x, div(n, x)]
      x -> [x]
    end)
  end

  def quadratic(a, b, c) do
    d = b ** 2 - 4 * a * c

    cond do
      d < 0 ->
        IO.puts("solution not possible")
        {:error}

      d == 0 ->
        IO.puts("one solution")
        x = (-b + :math.sqrt(b ** 2 - 4 * a * c)) / 2 * a
        {:ok, {x, x}}

      true ->
        x1 = (-b + :math.sqrt(b ** 2 - 4 * a * c)) / 2 * a
        x2 = (-b - :math.sqrt(b ** 2 - 4 * a * c)) / 2 * a
        {:ok, {x1, x2}}
    end
  end
end
