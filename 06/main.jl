include("../common/io_functions.jl")
using .CommonIO

struct AddOp end
struct MulOp end

apply_operation(numbers::AbstractVector{Int}, ::AddOp) = sum(numbers)
apply_operation(numbers::AbstractVector{Int}, ::MulOp) = prod(numbers)

# Convert string to operation type
const OPS = Dict("+" => AddOp(), "*" => MulOp())

function solve(numbers::Vector{Vector{Int}}, operations::Vector{SubString{String}})
    sum(apply_operation(nums, OPS[op]) for (nums, op) in zip(numbers, operations))
end

function solve(numbers_list::Vector{String}, operations::Vector{SubString{String}})    
    column_strings = [String([numbers_list[row][col] 
                              for row in 1:length(numbers_list) if col <= length(numbers_list[row])]) 
                      for col in 1:maximum(length, numbers_list)]
    
    # Strip whitespace and find problem boundaries (empty strings)
    stripped = strip.(column_strings)
    breaks = findall(==(""), stripped)
    split_indices = [0; breaks; length(stripped) + 1]
    
    # Join digits and parse into vector of numbers
    number_groups = [[parse(Int, stripped[j]) for j in split_indices[i]+1:split_indices[i+1]-1 if !isempty(stripped[j])] 
                     for i in 1:length(split_indices)-1]
    
    return solve(number_groups, operations)
end


input_list = CommonIO.read_input_lines(6)
numbers_list = [line for line in input_list[1:end-1] if !isempty(line)]

# Transpose rows to columns
rows = [parse.(Int, split(line)) for line in numbers_list]
numbers = [[rows[r][c] for r in 1:length(rows)] 
                 for c in 1:maximum(length, rows)]

operations = split(input_list[end])

println("Solution to part 1:\n", solve(numbers, operations)) # 4648618073226
println("Solution to part 2:\n", solve(numbers_list, operations)) # 7329921182115