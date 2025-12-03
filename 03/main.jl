include("../common/io_functions.jl")
using .CommonIO

get_index(bank::Array{Int}, num::Int) = findfirst(x -> x == num, bank)

function find_largest_combination(bank::Array{Int}, num_batteries)
    # Base case: Not enough digits available
    if length(bank) < num_batteries
        return 0
    end
    
    # Base case: Only need one digit, return the largest
    if num_batteries == 1
        largest = maximum(bank)
        return largest
    end
    
    # Valid range ensures enough digits remain for subsequent selections
    max_joltage = 0
    biggest_nums = unique(sort(bank[1:end - num_batteries + 1], rev=true))
    
    for biggest in biggest_nums
        biggest_id = get_index(bank, biggest)
        
        # Recursively find best combination for remaining positions
        next_largest = find_largest_combination(bank[biggest_id+1:end], num_batteries - 1)
        if next_largest == 0
            continue
        end
        maxx = biggest * 10^(num_batteries-1) + next_largest
        
        return maxx
    end

    return max_joltage
end

function solve(joltages::Vector{String}, num_batteries::Int)
    total = 0
    for bank in joltages
        total += find_largest_combination(parse.(Int, split(bank, "")), num_batteries)
    end
    return total
end

joltages = CommonIO.read_input_lines(3)
println("Solution to part 1:\n", solve(joltages, 2))
println("Solution to part 2:\n", solve(joltages, 12))