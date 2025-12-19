include("../common/io_functions.jl")
include("../common/timing.jl")

using .CommonIO
using .Timing
using DancingLinks
using ProgressBars

struct Shape
    matrix::Matrix{Int64}
end

struct Region
    size::Tuple{Int64, Int64}
    shapes::Vector{Int64}
end

function parse_input(lines::Vector{String})
    shapes = Vector{Shape}()
    regions = Vector{Region}()

    # Parse shapes: lines starting with digit followed by colon
    i = 1
    while i <= length(lines)
        line = lines[i]
        if !isempty(line) && length(line) >= 2 && line[2] == ':'
            matrix = zeros(Int64, 3, 3)
            for j in 1:3
                if i + j <= length(lines)
                    shape_line = lines[i + j]
                    for k in 1:min(3, length(shape_line))
                        matrix[j, k] = shape_line[k] == '#' ? 1 : 0
                    end
                end
            end
            push!(shapes, Shape(matrix))
            i += 4  # Skip the 3 shape lines + 1 for spacing
        else
            i += 1
        end
    end

    # Parse regions: lines containing 'x' (e.g., "4x4: 0 0 0 0 2 0")
    for line in lines
        if occursin("x", line) && occursin(":", line)
            parts = split(line, ": ")
            size = Tuple(parse.(Int64, split(parts[1], "x")))
            shape_ids = parse.(Int64, split(parts[2]))
            push!(regions, Region(size, shape_ids))
        end
    end

    return shapes, regions
end

function trim(mat::Matrix{Int})
    rows = findall(r -> any(mat[r, :] .== 1), 1:size(mat, 1))
    cols = findall(c -> any(mat[:, c] .== 1), 1:size(mat, 2))
    mat[minimum(rows):maximum(rows), minimum(cols):maximum(cols)]
end

function all_orientations(shape::Shape)
    mats = Matrix{Int}[]
    seen = Set{String}()

    function push_if_new(m)
        m = trim(m)
        key = string(m)
        if !(key in seen)
            push!(seen, key)
            push!(mats, m)
        end
    end

    m = shape.matrix
    for _ in 1:4
        push_if_new(m)
        m = reverse(transpose(m), dims=1)
    end

    m = reverse(shape.matrix, dims=2)
    for _ in 1:4
        push_if_new(m)
        m = reverse(transpose(m), dims=1)
    end

    return mats
end

function shape_cells(mat::Matrix{Int})
    [(r, c) for r in 1:size(mat,1), c in 1:size(mat,2) if mat[r,c] == 1]
end

function can_fit_region(region::Region, shapes::Vector{Shape})::Bool
    W, H = region.size
    # --- quick area prune ---
    total_area = 0
    for (i, k) in enumerate(region.shapes)
        if k > 0
            total_area += k * sum(shapes[i].matrix)
        end
    end
    total_area > W * H && begin
        return false
    end

    # --- column indexing ---
    cell_col(x, y) = (y - 1) * W + x
    n_cell_cols = W * H

    shape_offsets = Dict{Tuple{Int,Int}, Int}()
    col = n_cell_cols
    for (sid, k) in enumerate(region.shapes)
        for copy in 1:k
            col += 1
            shape_offsets[(sid, copy)] = col
        end
    end
    n_cols = col

    rows = Vector{Vector{Int}}()
    placement_count = 0

    # --- generate placements ---
    for (sid, count) in enumerate(region.shapes)
        if count == 0
            continue
        end

        orients = all_orientations(shapes[sid])

        for (oi, orient) in enumerate(orients)
            cells = shape_cells(orient)
            h = size(orient, 1)
            w = size(orient, 2)

            max_y = H - h + 1
            max_x = W - w + 1
            if max_y < 1 || max_x < 1
                continue
            end

            for y in 1:max_y, x in 1:max_x
                abs_cells = [(x + c - 1, y + r - 1) for (r,c) in cells]

                for copy in 1:count
                    row = Int[]
                    for (cx, cy) in abs_cells
                        push!(row, cell_col(cx, cy))
                    end
                    push!(row, shape_offsets[(sid, copy)])
                    push!(rows, row)
                    placement_count += 1
                end
            end
        end
    end

    if isempty(rows)
        return false
    end

    # --- build boolean matrix ---
    M = zeros(Bool, length(rows), n_cols)
    for (r, cols) in enumerate(rows)
        for c in cols
            M[r, c] = true
        end
    end

    # --- ADD SLACK ROWS FOR CELL COLUMNS (at-most-once) ---
    for c in 1:n_cell_cols
        slack = zeros(Bool, 1, n_cols)
        slack[1, c] = true
        M = vcat(M, slack)
    end

    # --- solve exact cover ---
    exact_cover(M; do_check=false)
    res = DancingLinks.solve(max_solutions=1, deterministic=true)
    return res
end

function solve(shapes::Vector{Shape}, regions::Vector{Region})
    n = length(regions)
    results = Vector{Bool}(undef, n)

    for (i, region) in ProgressBar(enumerate(regions))
        results[i] = can_fit_region(region, shapes)
    end

    return count(==(true), results)
end
lines = CommonIO.read_input_lines(12, true)
shapes, regions = parse_input(lines)

t1 = @elapsed result1 = solve(shapes, regions)
print_solution(1, result1, t1)
