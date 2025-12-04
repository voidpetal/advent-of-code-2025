include("../common/io_functions.jl")
using .CommonIO

function count_adjacent(map::Vector{String}, x::Int, y::Int)
    count = 0
    for dy in -1:1
        for dx in -1:1
            if (dx == 0 && dy == 0)
                continue
            end
            nx, ny = x + dx, y + dy
            if 1 <= nx <= length(map[1]) && 1 <= ny <= length(map)
                count += map[ny][nx] == '@' ? 1 : 0
            end
        end
    end
    return count
end

function get_removable_rolls(map::Vector{String})
    paper_rolls = []
    for y in 1:length(map)
        for x in 1:length(map[1])
            if map[y][x] == '@'
                count = count_adjacent(map, x, y)
                if count < 4
                    push!(paper_rolls, (x, y))
                end
            end
        end
    end
    return paper_rolls
end

function solve(map::Vector{String}, part::Int)
    map_copy = copy(map)
    total = 0
    while true
        removable_rolls = get_removable_rolls(map_copy)
        if length(removable_rolls) == 0
            break
        end
        total += length(removable_rolls)
        for (x, y) in removable_rolls
            map_copy[y] = map_copy[y][1:x-1] * '.' * map_copy[y][x+1:end]
        end

        if part == 1
            break
        end
    end
    return total
end


map_lines = CommonIO.read_input_lines(4)
println("Solution to part 1:\n", solve(map_lines, 1)) # 1551
println("Solution to part 2:\n", solve(map_lines, 2)) # 9784