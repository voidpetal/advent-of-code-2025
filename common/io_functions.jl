module CommonIO

export read_input_lines, parse_int_list

function read_input_lines(day::Int)
    filename = joinpath(string(day, pad=2), "input.txt")
    return readlines(abspath(filename))
end

function parse_int_list(lines::AbstractVector{<:AbstractString})
    valid_lines = filter(l -> !isempty(l), lines)
    return map(line -> parse(Int, line), valid_lines)
end

end