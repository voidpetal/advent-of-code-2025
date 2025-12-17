include("../common/io_functions.jl")
using .CommonIO

function combine_ranges(ranges::Vector{Vector{Int}})
    ranges = sort(ranges, by = r -> r[1])
    combined_ranges = Vector{Vector{Int}}()
    lower, upper = ranges[1][1], ranges[1][2]
    for i in 2:length(ranges)
        # For each range, check if it overlaps with the previous one
        if ranges[i][1] <= upper
            # Overlaps, extend the upper bound if needed
            upper = max(upper, ranges[i][2])
        else
            # Does not overlap, store the previous range
            push!(combined_ranges, [lower, upper])
            lower, upper = ranges[i][1], ranges[i][2]
        end
    end
    # Push the last range
    push!(combined_ranges, [lower, upper])
    return combined_ranges
end


function solve(ranges::Vector{Vector{Int}}, ids::Vector{Int}, part::Int)
    ids = sort(unique(ids))
    fresh = 0
    total_fresh_ids = 0
    ranges = combine_ranges(ranges)
    
    # For each range, find the count of IDs in that range
    for r in ranges
        total_fresh_ids += (r[2] - r[1] + 1)
        # Find first ID >= r[1]
        first_idx = searchsortedfirst(ids, r[1])
        # Find last ID <= r[2]
        last_idx = searchsortedlast(ids, r[2])
        
        # Count of IDs in this range
        if last_idx >= first_idx
            fresh += (last_idx - first_idx + 1)
        end
    end
    if part == 1
        return fresh
    else
        return total_fresh_ids
    end
end


input_list = CommonIO.read_input_lines(5)

ranges = [line for line in input_list if !isempty(line) && contains(line, "-")]
ids = [parse.(Int, line) for line in input_list if !isempty(line) && !contains(line, "-")]

ranges = map(line -> parse.(Int, split(line, "-")), ranges)


println("Part 1: ", solve(ranges, ids, 1))  # 613
println("Part 2: ", solve(ranges, ids, 2))  # 336495597913098