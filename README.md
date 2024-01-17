[![CI](https://github.com/wherrera10/ThreadSafeDicts.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/wherrera10/ThreadSafeDicts.jl/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/wherrera10/ThreadSafeDicts.jl/badge.svg?branch=master)](https://coveralls.io/github/wherrera10/ThreadSafeDicts.jl?branch=master)

# ThreadSafeDicts.jl
A thread-safe Dict type for Julia programming
<br />
<img src="https://github.com/wherrera10/ThreadSafeDicts.jl/blob/master/docs/src/spool.png">
<br /><br />


## Structs and Functions
<br />
    
    struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
        dlock::Threads.SpinLock
        d::Dict{K, V}
        ThreadSafeDict{K, V}() where V where K = new(Threads.SpinLock(), Dict{K, V}())
        ThreadSafeDict{K, V}(itr) where V where K = new(Threads.SpinLock(), Dict{K, V}(itr))
    end
    ThreadSafeDict() = ThreadSafeDict{Any,Any}()
    ThreadSafeDict(pairs::Vector{Pair{K,V}})   
<br />

Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass 
arguments to the d member Dict, unlock the spinlock, and then return what is returned by the Dict.

If there are going to be a large number of threads competing to update the `Dict`, causing most of the threads to 
be blocked at any given time, you may be better off keeping a `Dict` in a separate thread which accepts updates
via a `Channel` of `Pair`s.  YMMMV. 
<br /><br />

    getindex(dic::ThreadSafeDict, k)
<br />

    setindex!(dic::ThreadSafeDict, k, v)
<br />

    haskey(dic::ThreadSafeDict, k)
<br />

    get(dic::ThreadSafeDict, k, v)
<br />

    get!(dic::ThreadSafeDict, k, v)
<br />

    pop!(dic::ThreadSafeDict)
<br />

    empty!(dic::ThreadSafeDict)
<br />

    delete!(dic::ThreadSafeDict, k)
<br />

    length(dic::ThreadSafeDict)
<br />

    iterate(dic::ThreadSafeDict)
<br />

    iterate(dic::ThreadSafeDict, i)
<br />

    print(io::IO, dic::ThreadSafeDict)
<br /><br />

All of the above methods work as in those of the base Dict type. However, they all
lock a spinlock prior to passing the arguments to a base Dict within the struct, then
unlock the base Dict prior to returning the function call results. Thus, with a single
thread the functions are equivalent to those of a base Dict, but with multiple threads
thread access to the underlying Dict is serialized per ThreadSafeDict.

## Installation

## Installation

You may install the package from Github in the usual way, or to install the current master copy:
        
    using Pkg
    Pkg.add("http://github.com/wherrera10/ThreadSafeDicts.jl")
    
