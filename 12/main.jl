include("../common/io_functions.jl")
include("../common/timing.jl")

using .CommonIO
using .Timing

function parse_input(lines)
    shapes_fill = Int[]
    regions = Vector{Tuple{Tuple{Int, Int}, Vector{Int}}}()

    # read shape blocks like `0:` followed by three text lines
    i = 1
    n = length(lines)
    while i <= n
        if occursin(r"^\d+:\s*$", strip(lines[i]))
            # count '#' in the next three lines (safely handle short files)
            cnt = 0
            for j in 1:3
                s = i + j <= n ? lines[i + j] : ""
                @inbounds for k in 1:min(3, lastindex(s))
                    cnt += (s[k] == '#')
                end
            end
            push!(shapes_fill, cnt)
            i += 4
        else
            i += 1
        end
    end

    for line in lines
        m = match(r"^(\d+)x(\d+):\s*(.*)$", strip(line))
        if m !== nothing
            w, h = parse.(Int, m.captures[1:2])
            ids = parse.(Int, split(m.captures[3]))
            push!(regions, ((w, h), ids))
        end
    end

    return shapes_fill, regions
end

function can_fit(region::Tuple{Tuple{Int, Int}, Vector{Int}}, shape_fill::Vector{Int})
    (w, h), counts = region
    area = w * h
    total_required = 0
    @inbounds for (i, c) in enumerate(counts)
        total_required += shape_fill[i] * c
    end
    return area >= total_required
end

function solve(shape_fill, regions)
    sum(can_fit.(regions, Ref(shape_fill)))
end

lines = CommonIO.read_input_lines(12)
shapes, regions = parse_input(lines)

t1 = @elapsed result1 = solve(shapes, regions)
t2 = @elapsed result2 = 0  # Part 2 is a free star

print_solution(1, result1, t1) # 485
print_solution(2, result2, t2) # 0
