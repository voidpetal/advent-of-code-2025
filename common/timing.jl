module Timing

export format_time, print_solution

using Printf

const CYAN = "\e[36m"
const RESET = "\e[0m"

function format_time(seconds::Float64)
    if seconds < 0.001
        return @sprintf("%.2f μs", seconds * 1_000_000)
    elseif seconds < 1.0
        return @sprintf("%.2f ms", seconds * 1000)
    else
        return @sprintf("%.2f s", seconds)
    end
end

function print_solution(part::Int, result, time::Float64)
    time_str = format_time(time)
    println("Part $part: $result $CYAN($time_str)$RESET")
end

end
