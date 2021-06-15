[![Build status](https://ci.appveyor.com/api/projects/status/cfw6pe03rfn9qsoo?svg=true)](https://ci.appveyor.com/project/wherrera10/threadsafedicts.jl)
[![Build Status](https://travis-ci.org/wherrera10/ThreadSafeDicts.jl.svg?branch=master)](https://travis-ci.org/wherrera10/ThreadSafeDicts.jl)
[![Coverage Status](https://coveralls.io/repos/github/wherrera10/ThreadSafeDicts.jl/badge.svg?branch=master)](https://coveralls.io/github/wherrera10/ThreadSafeDicts.jl?branch=master)

# ThreadSafeDict.jl
A thread-safe Dict type for Julia programming

## Structs and Functions
<br />
    
    struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
        dlock::Threads.SpinLock
        d::Dict
        ThreadSafeDict{K, V}() where V where K = new(Threads.SpinLock(), Dict{K, V}())
        ThreadSafeDict{K, V}(itr) where V where K = new(Threads.SpinLock(), Dict{K, V}(itr))
    end
    ThreadSafeDict() = ThreadSafeDict{Any,Any}()
    ThreadSafeDict(pairs::Vector{Pair{K,V}})   
<br />

Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass 
arguments to the d member Dict, unlock the spinlock, and then return what is returned by the Dict.
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
    
