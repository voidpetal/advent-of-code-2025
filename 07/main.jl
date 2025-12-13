include("../common/io_functions.jl")
using .CommonIO

function solve(map_grid::Matrix{Char}, start_pos::Int)
    beams = Set([start_pos])
    split_count = 0
    for row in 2:size(map_grid, 2)
        splits = findall(==('^'), map_grid[:, row])
        # if any splits coincide with beams, increment split count, remove that beam and add two new beams
        for split in splits
            if split in beams
                split_count += 1
                delete!(beams, split)
                push!(beams, split - 1)
                push!(beams, split + 1)
            end
        end
    end
    return split_count
end

cache = Dict{Tuple{Int, Int}, Int}()
function solve(map_grid::Matrix{Char}, position::Int, row::Int)
    if (row, position) in keys(cache)
        return cache[(row, position)]
    end
    if position < 1 || position > size(map_grid, 1)
        return 0
    end
    if row > size(map_grid, 2)
        return 1
    end
    cell = map_grid[position, row]
    if cell == '^'
        result = solve(map_grid, position - 1, row + 1) + solve(map_grid, position + 1, row + 1)
    else
        result = solve(map_grid, position, row + 1)
    end
    cache[(row, position)] = result
    return result
end

solve(map_grid::Matrix{Char}, start_pos::CartesianIndex{2}) = solve(map_grid, start_pos[1], start_pos[2])


map_lines = CommonIO.read_input_lines(7)
map_grid = hcat(collect.(map_lines)...)
start_pos = findfirst(==('S'), map_grid)
println("Solution to part 1:\n", solve(map_grid, start_pos[1])) # 1566
println("Solution to part 2:\n", solve(map_grid, start_pos)) # 5921061943075