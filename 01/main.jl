include("../common/io_functions.jl")
include("../common/timing.jl")
using .CommonIO
using .Timing

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

t1 = @elapsed result1 = solve(rotations, false)
t2 = @elapsed result2 = solve(rotations, true)

print_solution(1, result1, t1)  # 1023
print_solution(2, result2, t2)  # 5899