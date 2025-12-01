include("../common/io_functions.jl")
using .CommonIO


function move_dial(arrow::Int, rotation::Char, times::Int)
    if rotation == 'R'
        summ = (arrow + times)
    elseif rotation == 'L'
        summ = (arrow - times)
    end
    return summ % 100, div(summ, 100)
end

function solve(rotations, manual::Bool)
    arrow = 50
    cnt = 0
    for rotation in rotations
        direction, times = rotation[1], parse(Int, rotation[2:end])
        if manual
            for _ in 1:times
                if direction == 'R'
                    arrow += 1
                elseif direction == 'L'
                    arrow -= 1
                end
                arrow %= 100
                if arrow == 0
                    cnt += 1
                end
            end
        else
            arrow, _ = move_dial(arrow, direction, times)
            if arrow == 0
                cnt += 1
            end
        end
    end
    return cnt
end

rotations = CommonIO.read_input_lines(1)

println("Solution to part 1:")
println(solve(rotations, false))

println("Solution to part 2:")
println(solve(rotations, true))