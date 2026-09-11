# ThreadSafeDicts.jl
A thread-safe `Dict` type for Julia programming

<br>
<img src="https://github.com/wherrera10/ThreadSafeDicts.jl/blob/master/docs/src/spool.png">
<br><br>

## Structs and Functions

### `ThreadSafeDict`

```julia
struct ThreadSafeDict{K,V} <: AbstractDict{K,V}
    dlock::ReentrantLock
    d::Dict{K,V}
    ThreadSafeDict{K,V}() where {K,V} = new(ReentrantLock(), Dict{K,V}())
    ThreadSafeDict{K,V}(d::Dict{K,V}) where {K,V} =
        new(ReentrantLock(), copy(d))
    ThreadSafeDict{K,V}(itr) where {K,V} =
        new(ReentrantLock(), Dict{K,V}(itr))
end

ThreadSafeDict()
ThreadSafeDict(d::Dict{K,V}) where {K,V}
ThreadSafeDict(itr)

Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass
arguments to the d member Dict, unlock the ReentrantLock, and then return what is returned by the Dict.
<br><br>


    getindex(dic::ThreadSafeDict, k)
<br>

    setindex!(dic::ThreadSafeDict, k, v)
<br>

    haskey(dic::ThreadSafeDict, k)
<br>

    get(dic::ThreadSafeDict, k, v)
<br>

    get!(dic::ThreadSafeDict, k, v)
<br>

    pop!(dic::ThreadSafeDict)
<br>

    empty!(dic::ThreadSafeDict)
<br>

    delete!(dic::ThreadSafeDict, k)
<br>

    length(dic::ThreadSafeDict)
<br>

    iterate(dic::ThreadSafeDict)
<br>

    iterate(dic::ThreadSafeDict, i)
<br>

    print(io::IO, dic::ThreadSafeDict)
<br><br>

All of the above methods work as in those of the base Dict type. However, they all
lock a ReentrantLock prior to passing the arguments to a base Dict within the struct, then
unlock the base Dict prior to returning the function call results. Thus, with a single
thread the functions are equivalent to those of a base Dict, but with multiple threads
thread access to the underlying Dict is serialized per ThreadSafeDict.


## Installation

You may install the package from Github in the usual way, or to install the current master copy:

    using Pkg
    Pkg.add("http://github.com/wherrera10/ThreadSafeDicts.jl")

