include("../common/io_functions.jl")
include("../common/timing.jl")
using .CommonIO
using .Timing
using PolygonAlgorithms
using ProgressBars

get_area(t1::Tuple{Float64, Float64}, t2::Tuple{Float64, Float64}) = prod(abs.(t1 .- t2) .+ 1)
build_rectangle(t1::Tuple{Float64, Float64}, t2::Tuple{Float64, Float64}) = [
    (t1[1], t1[2]),
    (t2[1], t1[2]),
    (t2[1], t2[2]),
    (t1[1], t2[2])
]

# Shoelace formula for polygon area
function polygon_area(vertices::Vector{Tuple{Float64, Float64}})
    xs = [v[1] for v in vertices]
    ys = [v[2] for v in vertices]
    
    return abs(sum(xs .* circshift(ys, -1)) - sum(circshift(xs, -1) .* ys)) / 2
end

# If all points of rectangle are inside the area described by red tiles
function is_valid_rectangle(tiles::Vector{Tuple{Float64, Float64}}, i::Int, j::Int)
    rectangle = build_rectangle(tiles[i], tiles[j])
    
    # Check if rectangle is inside polygon
    intersection = intersect_geometry(tiles, rectangle)
    
    # Invalid rectangle
    isempty(intersection) && return false

    # Calculate areas to verify rectangle is fully inside
    rect_area = abs(polygon_area(rectangle))
    intersect_area = sum(abs(polygon_area(p)) for p in intersection)
    
    # If areas match (within tolerance), rectangle is valid
    return isapprox(rect_area, intersect_area, rtol=1e-9)
end

function solve(tiles::Vector{Tuple{Float64, Float64}}, check_intersection::Bool=false)
    # Generate all pairs with their potential areas
    pairs = [(i, j, get_area(tiles[i], tiles[j]))
             for i in 1:length(tiles) 
             for j in i+1:length(tiles)]
    
    # Sort by area descending (largest first) for early termination
    sort!(pairs, by = x -> x[3], rev = true)
    
    max_area = 0
    check_intersection && (pairs = ProgressBars.ProgressBar(pairs))
    
    for (i, j, potential_area) in pairs
        # If potential area can't beat current max, stop
        potential_area <= max_area && break
        
        # Check if rectangle is valid
        if !check_intersection || is_valid_rectangle(tiles, i, j)
            max_area = potential_area
            check_intersection && break  # found best valid rectangle
        end
    end
    
    Int64(max_area)
end
    
red_tiles = CommonIO.read_input_lines(9) |> x -> map(line -> Tuple(parse.(Float64, split(line, ","))), x)

t1 = @elapsed result1 = solve(red_tiles)
t2 = @elapsed result2 = solve(red_tiles, true)

print_solution(1, result1, t1)  # 4749672288
print_solution(2, result2, t2)  # 1479665889
