include("../common/io_functions.jl")
using .CommonIO

function count_adjacent(map::Matrix{Char}, x::Int, y::Int)
    count = 0
    rows, cols = size(map)
    for dy in -1:1
        for dx in -1:1
            if (dx == 0 && dy == 0)
                continue
            end
            nx, ny = x + dx, y + dy
            if 1 <= ny <= rows && 1 <= nx <= cols
                count += (map[ny, nx] == '@')
            end
        end
    end
    return count
end

function get_removable_rolls(map::Matrix{Char})
    max_rolls = count(c -> c == '@', map)
    paper_rolls = Vector{Tuple{Int, Int}}(undef, max_rolls)
    idx = 1
    rows, cols = size(map)
    for y in 1:rows
        for x in 1:cols
            if map[y, x] == '@'
                c = count_adjacent(map, x, y)
                if c < 4
                    paper_rolls[idx] = (x, y)
                    idx += 1
                end
            end
        end
    end
    resize!(paper_rolls, idx - 1)
    return paper_rolls
end

function solve(map::Matrix{Char}, part::Int)
    map_copy = copy(map)
    total = 0
    while true
        removable_rolls = get_removable_rolls(map_copy)
        if length(removable_rolls) == 0
            break
        end
        total += length(removable_rolls)
        for (x, y) in removable_rolls
            map_copy[y, x] = '.'
        end

        if part == 1
            break
        end
    end
    return total
end


map_lines = CommonIO.read_input_lines(4)
map_grid = hcat(collect.(map_lines)...)
println("Part 1: ", solve(map_grid, 1))  # 1551
println("Part 2: ", solve(map_grid, 2))  # 9784