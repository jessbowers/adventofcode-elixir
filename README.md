# ElixirAoc2022

My [Advent of Code](https://adventofcode.com) 2022 workbook for [Elixir](https://elixir-lang.org).

The project makes use of the [Advent of Code Utils](https://hexdocs.pm/advent_of_code_utils/3.0.0/readme.html) project.

## Installation

    mix deps.get

    # in config/config.exs

    import Config

    config :advent_of_code_utils,
    session:
        "... cookie goes here ... "

    config :advent_of_code_utils,
        day: 6,
        year: 2022

## Setting up for a day

    # create scaffold
    mix aoc
    
    # just fetch data:
    mix aoc.get

## Running 

    > iex -S mix
    > recompile()
    > p1i()
    > p2i()
