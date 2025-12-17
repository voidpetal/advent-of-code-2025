include("../common/io_functions.jl")
include("../common/timing.jl")
using .CommonIO
using .Timing

distance(p1::Vector{Int}, p2::Vector{Int}) = sum(abs2, p1 .- p2)

function solve(coordinates::Vector{Vector{Int}}, N::Int)
    # Compute the distance matrix
    pairs_with_distances = [(distance(coordinates[i], coordinates[j]), i, j) 
                        for i in 1:length(coordinates) 
                        for j in i+1:length(coordinates)]
    sort!(pairs_with_distances)

    # Create circuits
    circuit_count = length(coordinates)
    points_to_circuit = [1:circuit_count;]
    for i in 1:N
        (_, p1, p2) = pairs_with_distances[i]
        # Find circuits containing either point
        circuit1, circuit2 = minmax(points_to_circuit[p1], points_to_circuit[p2])  # ensure c1 < c2
        # If both points part of the same circuit, skip
        if circuit1 == circuit2
            continue
        end

        # Merge circuits
        replace!(points_to_circuit, circuit2 => circuit1)
        circuit_count -= 1
        
        if circuit_count == 1
            # Part 2: multiply the x coordinates of the last two points connected
            return  coordinates[p1][1] * coordinates[p2][1]
        end
    end

    # Part 1
    # Sort circuits by size and find the product of the sizes of the three largest circuits
    circuit_sizes = Dict{Int,Int}()
    for circuit_id in points_to_circuit
        circuit_sizes[circuit_id] = get!(circuit_sizes, circuit_id, 0) + 1
    end
    prod(partialsort(collect(values(circuit_sizes)), 1:3, rev=true))
end


coordinates = CommonIO.read_input_lines(8) |> x -> map(line -> parse.(Int, split(line, ",")), x)

t1 = @elapsed result1 = solve(coordinates, 10^3)
t2 = @elapsed result2 = solve(coordinates, 10^6)

print_solution(1, result1, t1)  # 330786
print_solution(2, result2, t2)  # 3276581616
