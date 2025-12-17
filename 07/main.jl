include("../common/io_functions.jl")
using .CommonIO

function solve(map_grid::Matrix{Char}, start_pos::Int)
    beams = Set(start_pos)
    split_count = 0
    
    for row in 2:size(map_grid, 2)
        col = @view map_grid[:, row]
        for pos in eachindex(col)
            col[pos] == '^' && pos ∈ beams || continue
            split_count += 1
            delete!(beams, pos)
            union!(beams, (pos - 1, pos + 1))
        end
    end
    
    split_count
end

const cache = Dict{Tuple{Int, Int}, Int}()

function solve(map_grid::Matrix{Char}, position::Int, row::Int)
    # Check cache first
    haskey(cache, (row, position)) && return cache[(row, position)]
    
    # Early returns for boundary conditions
    position ∉ 1:size(map_grid, 1) && return 0
    row > size(map_grid, 2) && return 1
    
    # Compute result based on cell type
    result = map_grid[position, row] == '^' ?
        solve(map_grid, position - 1, row + 1) + solve(map_grid, position + 1, row + 1) :
        solve(map_grid, position, row + 1)
    
    cache[(row, position)] = result
end

solve(map_grid::Matrix{Char}, start_pos::CartesianIndex{2}) = solve(map_grid, start_pos[1], start_pos[2])

map_grid = CommonIO.read_input_lines(7) .|> collect |> splat(hcat)
start_pos = findfirst(==('S'), map_grid)
println("Part 1: ", solve(map_grid, start_pos[1]))  # 1566
println("Part 2: ", solve(map_grid, start_pos))     # 5921061943075