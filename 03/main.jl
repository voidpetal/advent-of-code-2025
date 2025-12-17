include("../common/io_functions.jl")
using .CommonIO

function find_largest_combination(bank::Vector{Int}, num_batteries)
    # Base case: Not enough digits available
    length(bank) < num_batteries && return 0
    
    # Base case: Only need one digit, return the largest
    num_batteries == 1 && return maximum(bank)
    
    # Valid range ensures enough digits remain for subsequent selections
    biggest_nums = unique(sort(bank[1:end - num_batteries + 1], rev=true))
    
    for biggest in biggest_nums
        biggest_id = findfirst(==(biggest), bank)
        
        # Recursively find best combination for remaining positions
        next_largest = find_largest_combination(bank[biggest_id+1:end], num_batteries - 1)
        
        # If no valid combination found, skip
        next_largest == 0 && continue
        
        return biggest * 10^(num_batteries-1) + next_largest
    end
    return 0
end

function solve(joltages::Vector{String}, num_batteries::Int)
    return sum(find_largest_combination([parse(Int, c) for c in bank], num_batteries) 
               for bank in joltages)
end

joltages = CommonIO.read_input_lines(3)
println("Part 1: ", solve(joltages, 2))   # 17412
println("Part 2: ", solve(joltages, 12))  # 172681562473501