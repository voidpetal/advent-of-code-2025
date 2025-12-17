# advent-of-code-2025

This repository contains my solutions to the puzzles in [Advent of Code 2025](https://adventofcode.com/2025). For the puzzle descriptions and inputs please visit the website.

All solutions are implemented in **Julia**.

## Running Solutions

If you want to run the code, please download the input file for each day in the respective folder under `<day>/input.txt`

Install dependencies:
```julia
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Run Individual Day
```bash
julia --project=. <day>/main.jl
```

### Run All Solutions
Run all days with festive output, timing, and answer verification:
```bash
julia --project=. run_all.jl
```