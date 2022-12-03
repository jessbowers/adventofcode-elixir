# ElixirAoc2022

Advent of Code 2022 in Elixir!

https://hexdocs.pm/advent_of_code_utils/3.0.0/readme.html

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
