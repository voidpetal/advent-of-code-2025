include("../common/io_functions.jl")
using .CommonIO

function is_invalid1(num::Int)
    s = string(num)
    l = length(s)
    # Can skip odd lengths, as they cannot contain two same parts
    if l % 2 != 0
        return false
    end
    mid = length(s) ÷ 2
    p1, p2 = s[1:mid], s[mid+1:end]
    if p1 == p2
        return true
    end
    return false
end

function is_invalid2(num::Int)
    pattern_len = 1
    s = string(num)
    l = length(s)
    while pattern_len <= l ÷ 2
        # If the length is not divisible by pattern_len, skip
        if l % pattern_len != 0
            pattern_len += 1
            continue
        end
        
        # Split the string into patterns of same length
        parts = [s[i:i+pattern_len-1] for i in 1:pattern_len:l-pattern_len+1]
        
        # All parts must be the same
        if all(x -> x == parts[1], parts)
            return true
        end
        pattern_len += 1
    end
    return false
end

function find_invalid(start_num::Int, end_num::Int, part::Int)
    invalid_ids = []
    for num in start_num:end_num
        if part == 1
            is_invalid = is_invalid1
        elseif part == 2
            is_invalid = is_invalid2
        end
        if is_invalid(num)
            push!(invalid_ids, num)
        end
    end
    return invalid_ids
end

function solve(id_ranges::Vector{String}, part::Int)
    count = 0
    for range in id_ranges
        start_num, end_num = parse.(Int, split(range, "-"))
        invalid_ids = find_invalid(start_num, end_num, part)
        if !isempty(invalid_ids)
            count += sum(invalid_ids)
        end
    end
    return count
end


id_ranges = split(CommonIO.read_input_lines(2)[1], ",")
println("Solution to part 1:")
println(solve(id_ranges, 1))

println("Solution to part 2:")
println(solve(id_ranges, 2))