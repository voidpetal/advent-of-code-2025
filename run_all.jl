#!/usr/bin/env julia

"""
Run all Advent of Code 2025 solutions
"""

using Printf

# ANSI color codes
const GREEN = "\e[32m"
const RED = "\e[31m"
const CYAN = "\e[36m"
const RESET = "\e[0m"

# Expected answers for each day [part1, part2]
const EXPECTED_ANSWERS = Dict(
    1  => [1023, 5899],
    2  => [20223751480, 30260171216],
    3  => [17412, 172681562473501],
    4  => [1551, 9784],
    5  => [613, 336495597913098],
    6  => [4648618073226, 7329921182115],
    7  => [1566, 5921061943075],
    8  => [330786, 3276581616],
    9  => [4749672288, 1479665889],
    10 => [457, 17576],
    11 => [764, 462444153119850],
    12 => [485, 0]
)

function format_time(seconds::Float64)
    if seconds < 0.001
        return @sprintf("%.2f μs", seconds * 1_000_000)
    elseif seconds < 1.0
        return @sprintf("%.2f ms", seconds * 1000)
    else
        return @sprintf("%.2f s", seconds)
    end
end

function parse_time(time_str::AbstractString)
    if occursin("μs", time_str)
        return parse(Float64, match(r"([\d.]+)", time_str).captures[1]) / 1_000_000
    elseif occursin("ms", time_str)
        return parse(Float64, match(r"([\d.]+)", time_str).captures[1]) / 1000
    elseif occursin("s", time_str)
        return parse(Float64, match(r"([\d.]+)", time_str).captures[1])
    end
    return 0.0
end

function verify_output(day::Int, output::String)
    expected = EXPECTED_ANSWERS[day]
    results = Int[]
    times = Float64[]
    
    # Extract numbers and timing from output
    for line in split(output, '\n')
        if occursin(r"Part [12]:", line)
            # Extract result
            m = match(r"Part [12]:\s*(\d+)", line)
            m !== nothing && push!(results, parse(Int, m.captures[1]))
            
            # Extract timing
            t = match(r"\(([\d.]+\s*(?:μs|ms|s))\)", line)
            if t !== nothing
                push!(times, parse_time(t.captures[1]))
            else
                push!(times, 0.0)
            end
        end
    end
    
    length(results) != 2 && return (false, false, 0.0, 0.0)
    length(times) != 2 && (times = [0.0, 0.0])
    
    part1_correct = expected[1] === nothing || results[1] == expected[1]
    part2_correct = expected[2] === nothing || results[2] == expected[2]
    
    return (part1_correct, part2_correct, times[1], times[2])
end

function run_day(day::Int)
    day_str = lpad(day, 2, '0')
    script_path = joinpath(@__DIR__, day_str, "main.jl")
    
    !isfile(script_path) && return (false, false, false, 0.0, 0.0)
    
    println("   🎄 Day $day_str 🎄")
    println()
    
    # Run the script using shell command to capture output
    try
        cmd = `julia --project=$(@__DIR__) $script_path`
        output_str = read(cmd, String)
        
        # Verify results and extract timing
        part1_correct, part2_correct, part1_time, part2_time = verify_output(day, output_str)
        
        # Print with color coding (timing already included in output)
        for line in split(output_str, '\n')
            if occursin(r"Part [12]:", line)
                # Determine which part
                is_part1 = occursin(r"Part 1:", line)
                correct = is_part1 ? part1_correct : part2_correct
                color = correct ? GREEN : RED
                status = correct ? "✓" : "✗"
                println("   $color$status $line$RESET")
            elseif !isempty(strip(line)) && !occursin(r"^[\d.]+%", line)
                # Skip progress bars
                println("   $line")
            end
        end
        
        println()
        return (true, part1_correct, part2_correct, part1_time, part2_time)
    catch e
        println("   ❌ Error running Day $day_str")
        println()
        return (false, false, false, 0.0, 0.0)
    end
end

function main()
    println()
    println("   ✨ ADVENT OF CODE 2025 - ALL SOLUTIONS ✨")
    println()
    
    completed = 0
    correct_parts = 0
    total_parts = 0
    total_time = 0.0
    
    for day in 1:12
        ran, part1_ok, part2_ok, t1, t2 = run_day(day)
        if ran
            completed += 1
            total_parts += 2
            total_time += (t1 + t2)
            part1_ok && (correct_parts += 1)
            part2_ok && (correct_parts += 1)
        end
    end
    
    println("🎄 " * "═"^58 * " 🎄")
    println("   ⭐ Completed: $completed/12 days ⭐")
    println("   $(GREEN)✓ Correct: $correct_parts/$total_parts parts$RESET")
    println("   $(CYAN)⏱  Total time: $(format_time(total_time))$RESET")
    println("🎄 " * "═"^58 * " 🎄")
    println()
end

main()
