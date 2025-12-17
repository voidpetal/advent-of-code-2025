include("../common/io_functions.jl")
using .CommonIO

function has_repeated_pattern(s::AbstractString, pattern_len::Int)
    length(s) % pattern_len != 0 && return false
    pattern = s[1:pattern_len]
    return all(s[i:i+pattern_len-1] == pattern for i in 1:pattern_len:length(s)-pattern_len+1)
end

is_invalid1(num::Int) = let s = string(num), mid = length(s) ÷ 2
    iseven(length(s)) && s[1:mid] == s[mid+1:end]
end

is_invalid2(num::Int) = let s = string(num)
    any(has_repeated_pattern(s, len) for len in 1:length(s)÷2)
end

function find_invalid(range::AbstractString, validator::Function)
    start_num, end_num = parse.(Int, split(range, "-"))
    filter(validator, start_num:end_num)
end

function solve(id_ranges::Vector{SubString{String}}, part::Int)
    validator = part == 1 ? is_invalid1 : is_invalid2
    sum(sum(find_invalid(range, validator)) for range in id_ranges)
end

id_ranges = split(CommonIO.read_input_lines(2)[1], ",")
println("Part 1: ", solve(id_ranges, 1))  # 20223751480
println("Part 2: ", solve(id_ranges, 2))  # 30260171216
