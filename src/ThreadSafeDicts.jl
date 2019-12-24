module ThreadSafeDicts

using Distributed

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.delete!, Base.print, Base.iterate

export ThreadSafeDict

""" 
    ThreadSafeDict(pairs::Vector{Pair{K,V}})   
Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass 
arguments to the d member Dict, unlock the spinlock, and then return what is returned by the Dict.
"""
struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
    dlock::Threads.SpinLock
    d::Dict
    ThreadSafeDict{K, V}() where V where K = ThreadSafeDict(SpinLock(), Dict{K, V}())
    ThreadSafeDict{K, V}(itr) where V where K = ThreadSafeDict(SpinLock(), Dict{K, V}(itr))
end

function getindex(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    v = getindex(dic.d, k)
    unlock(dic.dlock)
    return v
end

function setindex!(dic::ThreadSafeDict, v, k)
    lock(dic.dlock)
    h = setindex!(dic.d, v,  k)
    unlock(dic.dlock)
    return h
end

function haskey(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    b = haskey(dic.d, k)
    unlock(dic.dlock)
    return b
end

function get(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    v = get(dic.d, k, v)
    unlock(dic.dlock)
    return v
end

function get!(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    v = get!(dic.d, k, v)
    unlock(dic.dlock)
    return v
end

function pop!(dic::ThreadSafeDict)
    lock(dic.dlock)
    p = pop!(dic.d, k, v)
    unlock(dic.dlock)
    return p
end

function empty!(dic::ThreadSafeDict)
    lock(dic.dlock)
    d = empty!(dic.d)
    unlock(dic.dlock)
    return d
end

function delete!(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    p = delete!(dic.d, k)
    unlock(dic.dlock)
    return p
end

function iterate(dic::ThreadSafeDict)
    lock(dic.dlock)
    p = iterate(dic.d)
    unlock(dic.dlock)
    return p
end

function iterate(dic::ThreadSafeDict, i)
    lock(dic.dlock)
    p = iterate(dic.d, i)
    unlock(dic.dlock)
    return p
end  


end # module
