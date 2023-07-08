using PerformanceTestTools

PerformanceTestTools.@include_foreach(
    "test_threaded.jl",
    [nothing,
    ["JULIA_NUM_THREADS" => Threads.nthreads() > 1 ? "1" : "2"],
    ],
)

PerformanceTestTools.@include_foreach(
    "Szymański.jl",
    [nothing,
    ["JULIA_NUM_THREADS" => string(Threads.nthreads())],
    ],
)
