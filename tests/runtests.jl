using Distributed
using Test
using ThreadSafeDicts
function testThreadSafeDict()
    dict = ThreadSafeDict{String,Int64}(["a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1])

    @test dict["b"] == 1 && dict["e"] == 3
  
    @distributed for k in keys(dict)
        dict[k] = dict[k] * 100
    end

    x = dict["extra"]
    @test x == -100
    dict["extra"] = 0
    y = fibr["extra"]
    @test y == 0   
       
    empty!(dict)
    
    @distributed for i in 1:1000
        dict[string(i)] = i
    end   
    @test length(dict) = 1000
end

testBackedUpImmutableDict()
