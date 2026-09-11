using ThreadSafeDicts
using Test

function testThreadSafeDicts()
    dict = ThreadSafeDict()
    dict = ThreadSafeDict{String,Int64}()
    @test isempty(dict)
    dict["ten"] = 10
    dict["twenty"] = 20
    delete!(dict, "ten")
    @test pop!(dict) == ("twenty" => 20)
    @test isempty(dict)
    dict = ThreadSafeDict{String,Int64}(["a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1])

    @test dict["b"] == 1 && dict["e"] == 3
    Threads.@threads for k in collect(keys(dict))
        dict[k] *= 100
    end

    x = get!(dict, "another", 77)
    @test x == 77
    @test dict["e"] == 300
    @test get(dict, "e", nothing) == 300
    dict["extra"] = 0
    y = dict["extra"]
    @test y == 0
    @test haskey(dict, "a") == true

    @test pop!(dict, "extra") == 0
    @test !haskey(dict, "extra")
    @test pop!(dict, "missing", 99) == 99
    @test_throws KeyError pop!(dict, "missing")

    empty!(dict)

    y = 77
    func() = isqrt(y)
    x = get!(func, dict, "another")
    @test x == 8
    @test dict["another"] == 8

    empty!(dict)

    y = 77
    x = get(dict, "another") do
        isqrt(y)
    end
    @test x == 8
    @test !haskey(dict, "another")
    @test_throws KeyError dict["another"]

    empty!(dict)

    dict["existing"] = 10
    x = get!(dict, "existing") do
        error("callback should not be called")
    end
    @test x == 10

    x = get(dict, "existing") do
        error("callback should not be called")
    end
    @test x == 10

    empty!(dict)

    dict["value"] = 10
    x = get!(dict, "outer") do
        dict["value"] + 5
    end
    @test x == 15
    @test dict["outer"] == 15

    x = get(dict, "another") do
        dict["value"] + 7
    end
    @test x == 17

    empty!(dict)

    @test_throws KeyError dict["missing"]
    dict["aftererror"] = 123
    @test dict["aftererror"] == 123

    Threads.@threads for i in 1:1000
        dict[string(i)] = i
    end

    @test ((x, y) = iterate(dict)) != nothing
    @test iterate(dict, y) != nothing

    @test length(dict) == 1000
    empty!(dict)

    dict["a"] = 1
    dict["b"] = 2
    dict["c"] = 3
    state = iterate(dict)
    @test state != nothing
    @test length(state[2][1]) == 3

    dict["d"] = 4
    delete!(dict, "a")

    items = Pair[]
    push!(items, state[1])
    nextstate = state[2]
    while (next = iterate(dict, nextstate)) !== nothing
        push!(items, next[1])
        nextstate = next[2]
    end

    @test length(items) == 3
    @test Set(items) == Set(["a" => 1, "b" => 2, "c" => 3])
    @test !("d" => 4 in items)

    empty!(dict)

    Threads.@threads for i in 1:1000
        sleep(rand() / 100)
        dict["number"] = i
    end
    @test dict["number"] >= 1000 / Threads.nthreads()
    println("testing printing: ", dict)
end

testThreadSafeDicts()

true
