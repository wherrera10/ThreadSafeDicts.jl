using PerformanceTestTools

threadtests = Any[
    nothing,
    ["JULIA_NUM_THREADS" => Threads.nthreads() > 1 ? "1" : "2"],
]

ncpus = Sys.CPU_THREADS

if ncpus >= 4
    push!(threadtests, ["JULIA_NUM_THREADS" => "4"])
end

if ncpus >= 8
    push!(threadtests, ["JULIA_NUM_THREADS" => "8"])
end

PerformanceTestTools.@include_foreach(
    "test_threaded.jl",
    threadtests,
)

PerformanceTestTools.@include_foreach(
    "Szymański.jl",
    [nothing,
    ["JULIA_NUM_THREADS" => string(Threads.nthreads())],
    ],
)
