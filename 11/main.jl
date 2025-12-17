include("../common/io_functions.jl")
using .CommonIO

function build_graph(edges::Vector{String})
    graph = Dict{String, Vector{String}}()
    for line in edges
        src, dests = split(line, ": ")
        graph[src] = split(dests)
    end
    return graph
end

function count_unique_paths(graph::Dict{String, Vector{String}}, node::String, 
                           visited::Set{String}=Set{String}(), 
                           constraints::Vector{String}=Vector{String}(),
                           cache::Dict=Dict{Tuple{String, Vector{String}}, Int}())::Int
    # Base case: reached destination
    node == "out" && return isempty(constraints) ? 1 : 0
    
    # Check cache
    cache_key = (node, sort(constraints))
    haskey(cache, cache_key) && return cache[cache_key]
    
    # Update constraints if this node satisfies one
    new_constraints = filter(c -> c != node, constraints)
    
    # Count paths through all unvisited neighbors
    total_paths = 0
    for neighbor in get(graph, node, String[])
        neighbor in visited && continue
        
        new_visited = all(islowercase, neighbor) ? union(visited, [neighbor]) : visited
        total_paths += count_unique_paths(graph, neighbor, new_visited, new_constraints, cache)
    end
    
    return cache[cache_key] = total_paths
end

function solve(graph::Dict{String, Vector{String}}, part2::Bool=false)::Int
    start_node = part2 ? "svr" : "you"
    required_visits = part2 ? ["dac", "fft"] : String[]
    count_unique_paths(graph, start_node, Set{String}(), required_visits)
end

edges = CommonIO.read_input_lines(11)
graph = build_graph(edges)

println("Solution to part 1:\n", solve(graph)) # 764
println("Solution to part 2:\n", solve(graph, true)) # 462444153119850