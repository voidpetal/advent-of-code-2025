include("../common/io_functions.jl")
using .CommonIO

distance(p1::NTuple{3, Int}, p2::NTuple{3, Int}) = sqrt(sum((p1[i] - p2[i])^2 for i in 1:3))
distance(p1::Vector{Int}, p2::Vector{Int}) = distance((p1[1], p1[2], p1[3]), (p2[1], p2[2], p2[3]))

function solve(coordinates::Vector{Vector{Int}}, N::Int)
    # Get all pairs of points without repetition
    point_pairs = [(i, j) for i in 1:length(coordinates), j in 1:length(coordinates) if i < j]
    
    # Compute the distance matrix
    distances = [distance(coordinates[i], coordinates[j]) for (i, j) in point_pairs]

    # Sort the distances
    sorted_indices = sortperm(distances)

    # Create circuits
    circuits = [[p] for p in 1:length(coordinates)]
    for i in sorted_indices[1:N]
        (p1, p2) = point_pairs[i]
        # If both points part of the same circuit, skip
        found_circuit = false
        for circuit in circuits
            if p1 in circuit && p2 in circuit
                found_circuit = true
                break
            end
        end
        if found_circuit
            continue
        end

        # Find circuits containing either point
        circuit1 = findfirst(c -> p1 in c, circuits)
        circuit2 = findfirst(c -> p2 in c, circuits)
        if circuit1 !== nothing && circuit2 !== nothing
            # Merge circuits
            append!(circuits[circuit1], circuits[circuit2])
            deleteat!(circuits, circuit2)
        elseif circuit1 !== nothing
            push!(circuits[circuit1], p2)
        elseif circuit2 !== nothing
            push!(circuits[circuit2], p1)
        else
            push!(circuits, [p1, p2])
        end
        if length(circuits) == 1
            println("All points connected into a single circuit.")
            # Part 2: multiply the x coordinates of the last two points connected
            return  coordinates[p1][1] * coordinates[p2][1]
        end
    end

    # Part 1
    # Sort circuits by size
    sort!(circuits, by = c -> -length(c))
    # Find product of the sizes of 3 largest circuits
    prod(map(c ->length(c), circuits[1:3]))
end


coordinates = CommonIO.read_input_lines(8) |> x -> map(line -> parse.(Int, split(line, ",")), x)

println("Solution to part 1:\n", solve(coordinates, 1000)) # 330786
println("Solution to part 1:\n", solve(coordinates, 499500)) # 3276581616
