using Distributed
using ThreadSafeDicts

using Test

Threads.nthreads() == 1 && println("Hmm, you only have one thread allocated for Julia.")

function testThreadSafeDicts()
    dict = ThreadSafeDict{String,Int64}(["a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1])

    @test dict["b"] == 1 && dict["e"] == 3
    @Threads.threads for k in collect(keys(dict))
        dict[k] *= 100
    end

    x = get!(dict, "another", 77)
    @test x == 77
    @test dict["e"] == 300
    dict["extra"] = 0
    y = dict["extra"]
    @test y == 0
    @test haskey(dict, "a") == true
       
    empty!(dict)
    
    @sync begin
        @Threads.threads for i in 1:1000
            dict[string(i)] = i
        end 
    end
    
    @test ((x, y) = iterate(dict)) != nothing
    @test iterate(dict, y) != nothing
       
    @test length(dict.d) == 1000
end

testThreadSafeDicts()
