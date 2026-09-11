using ThreadSafeDicts
using Test

function testThreadSafeDicts()
    @testset "Constructors and basic operations" begin
        dict = ThreadSafeDict()
        dict = ThreadSafeDict{String,Int64}()

        @test isempty(dict)
        dict["ten"] = 10
        dict["twenty"] = 20
        delete!(dict, "ten")
        @test pop!(dict) == ("twenty" => 20)
        @test isempty(dict)

        dict = ThreadSafeDict{String,Int64}([
            "a" => 0, "b" => 1, "c" => 1, "d" => 2,
            "e" => 3, "f" => 5, "g" => 8, "h" => 13,
            "i" => 21, "j" => 34, "extra" => -1
        ])

        @test dict["b"] == 1
        @test dict["e"] == 3

        Threads.@threads for k in collect(keys(dict))
            dict[k] *= 100
        end

        x = get!(dict, "another", 77)
        @test x == 77
        @test dict["e"] == 300
        @test get(dict, "e", nothing) == 300

        dict["extra"] = 0
        @test dict["extra"] == 0
        @test haskey(dict, "a")

        @test pop!(dict, "extra") == 0
        @test !haskey(dict, "extra")
        @test pop!(dict, "missing", 99) == 99
        @test_throws KeyError pop!(dict, "missing")

        empty!(dict)
        @test isempty(dict)
    end

    @testset "get and get!" begin
        dict = ThreadSafeDict{String,Int64}()

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
    end

    @testset "Exception safety" begin
        dict = ThreadSafeDict{String,Int64}()

        @test_throws KeyError dict["missing"]
        dict["aftererror"] = 123
        @test dict["aftererror"] == 123

        @test_throws ErrorException get!(dict, "error") do
            error("expected error")
        end
        dict["aftergeterror"] = 456
        @test dict["aftergeterror"] == 456

        @test_throws ErrorException get(dict, "error") do
            error("expected error")
        end
        dict["aftergeterror2"] = 789
        @test dict["aftergeterror2"] == 789
    end

    @testset "Iteration" begin
        dict = ThreadSafeDict{String,Int64}()

        for i in 1:1000
            dict[string(i)] = i
        end

        state = iterate(dict)
        @test state != nothing

        y = state[2]
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
        @test !(("d" => 4) in items)

        # A new iteration sees the current contents.
        @test Set(collect(dict)) == Set(["b" => 2, "c" => 3, "d" => 4])
    end

    @testset "AbstractDict interface" begin
        dict = ThreadSafeDict{String,Int64}()

        @test dict isa AbstractDict
        @test keytype(dict) == String
        @test valtype(dict) == Int64
        @test eltype(dict) == Pair{String,Int64}

        @test isempty(dict)
        @test length(dict) == 0

        dict["a"] = 1
        dict["b"] = 2

        @test collect(keys(dict)) |> Set == Set(["a", "b"])
        @test collect(values(dict)) |> Set == Set([1, 2])
        @test collect(pairs(dict)) |> Set == Set(["a" => 1, "b" => 2])
        @test collect(dict) |> Set == Set(["a" => 1, "b" => 2])
    end

    @testset "Concurrent insertion and replacement" begin
        dict = ThreadSafeDict{String,Int64}()

        Threads.@threads for i in 1:1000
            dict[string(i)] = i
        end

        @test length(dict) == 1000

        empty!(dict)

        Threads.@threads for i in 1:1000
            sleep(rand() / 100)
            dict["number"] = i
        end

        @test dict["number"] >= 1000 / Threads.nthreads()
    end

    @testset "Concurrent get!" begin
        dict = ThreadSafeDict{String,Int64}()

        Threads.@threads for i in 1:1000
            get!(dict, "shared", i)
        end

        @test dict["shared"] >= 1
        @test dict["shared"] <= 1000
        @test length(dict) == 1

        empty!(dict)

        calls = Threads.Atomic{Int}(0)

        Threads.@threads for i in 1:1000
            get!(dict, "shared") do
                Threads.atomic_add!(calls, 1)
                i
            end
        end

        @test length(dict) == 1
        @test calls[] == 1
    end

    @testset "Concurrent deletion" begin
        dict = ThreadSafeDict{Int,Int}()

        for i in 1:1000
            dict[i] = i
        end

        Threads.@threads for i in 1:1000
            delete!(dict, i)
        end

        @test isempty(dict)
    end

    @testset "Concurrent pop!" begin
        dict = ThreadSafeDict{Int,Int}()

        for i in 1:1000
            dict[i] = i
        end

        Threads.@threads for i in 1:1000
            pop!(dict, i, nothing)
        end

        @test isempty(dict)

        for i in 1:1000
            dict[i] = i
        end

        popped = Threads.Atomic{Int}(0)

        Threads.@threads for i in 1:1000
            value = pop!(dict, i, nothing)
            value === nothing || Threads.atomic_add!(popped, 1)
        end

        @test popped[] == 1000
        @test isempty(dict)
    end

    @testset "Concurrent mixed operations" begin
        dict = ThreadSafeDict{Int,Int}()

        Threads.@threads for i in 1:10000
            key = i % 100
            dict[key] = i
            get(dict, key, nothing)
            haskey(dict, key)
            length(dict)
        end

        @test !isempty(dict)
        @test length(dict) <= 100
        @test all(haskey(dict, i) for i in 0:99)
    end

    @testset "Constructor does not alias source Dict" begin
        source = Dict("a" => 1)
        dict = ThreadSafeDict(source)

        source["b"] = 2
        @test haskey(dict, "a")
        @test !haskey(dict, "b")

        dict["c"] = 3
        @test !haskey(source, "c")
    end

    @testset "Concurrent iteration" begin
        dict = ThreadSafeDict{Int,Int}()

        for i in 1:1000
            dict[i] = i
        end

        snapshots = Threads.Atomic{Int}(0)

        Threads.@threads for i in 1:100
            count = 0
            for (key, value) in dict
                @assert key == value
                count += 1
            end
            count == 1000 && Threads.atomic_add!(snapshots, 1)
        end

        @test snapshots[] == 100
    end

    @testset "Printing and empty!" begin
        dict = ThreadSafeDict{String,Int64}()

        println("testing printing: ", dict)

        @test isempty(dict)
        @test length(dict) == 0

        dict["a"] = 1
        dict["b"] = 2

        @test length(dict) == 2

        empty!(dict)

        @test isempty(dict)
        @test length(dict) == 0
    end
end

testThreadSafeDicts()

true


true
