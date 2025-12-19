include("../common/io_functions.jl")
include("../common/timing.jl")
using .CommonIO
using .Timing
using JuMP
using HiGHS

function parse_input(line::String)::Tuple{Vector{Int}, Vector{Vector{Int}}, Vector{Int}}
    # Parse: "[indicators] (btn1) (btn2) ... {joltages}"
    indicators = [Int(c == '#') for c in match(r"\[(.*)\]", line).captures[1]]
    buttons = [parse.(Int, split(m.captures[1], ",")) .+ 1 
               for m in eachmatch(r"\(([^)]*)\)", line)]  # Convert to 1-indexed
    joltages = parse.(Int, split(match(r"\{(.*)\}", line).captures[1], ","))
    return (indicators, buttons, joltages)
end

function count_fewest_presses(target::Vector{Int}, buttons::Vector{Vector{Int}}, part2::Bool=false)
    # Build button activation matrix: A[i,j] = 1 if button j affects counter i
    A = zeros(Int, length(target), length(buttons))
    for (j, btn) in enumerate(buttons), i in btn
        A[i, j] = 1
    end

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, x[1:length(buttons)] >= 0, Int)
    
    if part2
        # Part 2: Direct addition (A*x = target)
        @constraint(model, A * x .== target)
    else
        # Part 1: XOR behavior (A*x ≡ target mod 2)
        @variable(model, y[1:length(target)] >= 0, Int)
        @constraint(model, A * x .== target .+ 2 .* y)
    end
    
    @objective(model, Min, sum(x))
    optimize!(model)

    return termination_status(model) == OPTIMAL ? round(Int, objective_value(model)) : 0
end

function solve(manual::Vector{String}, part2::Bool=false)
    parsed = parse_input.(manual)
    indicators, buttons, joltages = [getindex.(parsed, i) for i in 1:3]
    
    targets = part2 ? joltages : indicators
    sum(count_fewest_presses.(targets, buttons, part2))
end


manual = CommonIO.read_input_lines(10)

t1 = @elapsed result1 = solve(manual)
t2 = @elapsed result2 = solve(manual, true)

print_solution(1, result1, t1)  # 457
print_solution(2, result2, t2)  # 17576