include("../common/io_functions.jl")
using .CommonIO

function apply_operation(numbers::Vector{Int}, operation::SubString{String})
    if operation == "+"
        return sum(numbers)
    elseif operation == "*"
        return prod(numbers)
    else
        error("Unknown operation: $operation")
    end
end


function solve(numbers::Matrix{Int64}, operations::Vector{SubString{String}})
    results = Vector{Int}()
    for i in 1:length(operations)
        result = apply_operation(numbers[i, :], operations[i])
        push!(results, result)            
    end
    return sum(results)
end

function solve(numbers_list::Vector{String}, operations::Vector{SubString{String}})
    
    # Split into matrix of characters and rotate left by 1
    numbers = map(line -> split(line, ""), numbers_list)
    numbers = hcat(collect.(numbers)...)

    # Convert " " to ""
    numbers = replace(numbers, " " => "")

    # Merge the number strings by row
    merged_numbers = [join(numbers[row, :]) for row in 1:size(numbers, 1)]
    
    # Translate to matrix by taking rows  between '' values
    breaks = findall(x -> x == "", merged_numbers)
    split_indices = vcat(0, breaks, length(merged_numbers) + 1)
    merged_numbers = [parse.(Int, merged_numbers[split_indices[i]+1 : split_indices[i+1]-1]) for i in 1:length(split_indices)-1]

    # Pad with zeros or ones, depending on operation
    longest_length = maximum(length.(merged_numbers))
    for i in 1:length(merged_numbers)
        if operations[i] == "+"
            while length(merged_numbers[i]) < longest_length
                push!(merged_numbers[i], 0)
            end
        elseif operations[i] == "*"
            while length(merged_numbers[i]) < longest_length
                push!(merged_numbers[i], 1)
            end
        end
    end

    # Convert to a matrix
    numbers = hcat(collect.(merged_numbers)...)
    
    # Transpose to get columns as rows
    numbers = permutedims(numbers)
    return solve(numbers, operations)
end


input_list = CommonIO.read_input_lines(6)
numbers_list = [line for line in input_list[1:end-1] if !isempty(line)]
numbers = map(line -> parse.(Int, split(line)), numbers_list)
numbers = hcat(collect.(numbers)...)
operations = split(input_list[end])

println("Solution to part 1:\n", solve(numbers, operations)) # 4648618073226
println("Solution to part 2:\n", solve(numbers_list, operations)) # 7329921182115