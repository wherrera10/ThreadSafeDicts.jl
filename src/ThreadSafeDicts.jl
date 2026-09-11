""" ThreadSafeDicts package source code """

module ThreadSafeDicts

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.haskey, Base.delete!, Base.print, Base.iterate, Base.length
export ThreadSafeDict

""" 
    ThreadSafeDict(pairs::Vector{Pair{K,V}})

Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass 
arguments to the d member Dict, unlock the spinlock, and then return what is returned by the Dict.
"""
struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
    dlock::ReentrantLock
    d::Dict{K, V}
    ThreadSafeDict{K, V}() where V where K = new(ReentrantLock(), Dict{K, V}())
    ThreadSafeDict{K, V}(d::Dict{K, V}) where V where K = new(ReentrantLock(), copy(d))
    ThreadSafeDict{K, V}(itr) where V where K = new(ReentrantLock(), Dict{K, V}(itr))
end

ThreadSafeDict(d::Dict{K, V}) where V where K = ThreadSafeDict{K, V}(d)

ThreadSafeDict() = ThreadSafeDict{Any,Any}()

function ThreadSafeDict(itr)
    d = Dict(itr)
    ThreadSafeDict(d)
end

"""
    getindex(dic::ThreadSafeDict, k)
    
Get the value at key index k.
"""
function getindex(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        dic.d[k]
    finally
        unlock(dic.dlock)
    end
end

"""
    setindex!(dic::ThreadSafeDict, k, v)
    
Set the value at key index k to v.
"""
function setindex!(dic::ThreadSafeDict, v, k)
    lock(dic.dlock)
    try
        dic.d[k] = v
    finally
        unlock(dic.dlock)
    end
end

"""
    haskey(dic::ThreadSafeDict, k)

Return true if key k is in the dict, else return false.
"""
function haskey(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        haskey(dic.d, k)
    finally
        unlock(dic.dlock)
    end
end

"""
    get(dic::ThreadSafeDict, k, v)
    
Get value at key k if exists, otherwise return v
"""
function get(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    try
        get(dic.d, k, v)
    finally
        unlock(dic.dlock)
    end
end

"""
    get(f::Function, dic::ThreadSafeDict, k)
    
Get value at key k if exists, otherwise return f()
"""
function get(f::Function, dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        haskey(dic.d, k) ? dic.d[k] : f()
    finally
        unlock(dic.dlock)
    end
end

"""
    get!(dic::ThreadSafeDict, k, v)
    
Get value at key k if exists, otherwise set value at k to v and return v.
"""
function get!(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    try
        get!(dic.d, k, v)
    finally
        unlock(dic.dlock)
    end
end

"""
    get!(f::Function, dic::ThreadSafeDict, k)
    
Get value at key k if exists, otherwise set value at k to f() and return that value.
"""
function get!(f::Function, dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        if haskey(dic.d, k)
            dic.d[k]
        else
            v = f()
            dic.d[k] = v
            v
        end
    finally
        unlock(dic.dlock)
    end
end

"""
    pop!(dic::ThreadSafeDict)
    
remove and return a key-value pair from the Dict
"""
function pop!(dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        pop!(dic.d)
    finally
        unlock(dic.dlock)
    end
end

function pop!(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        pop!(dic.d, k)
    finally
        unlock(dic.dlock)
    end
end

function pop!(dic::ThreadSafeDict, k, default)
    lock(dic.dlock)
    try
        pop!(dic.d, k, default)
    finally
        unlock(dic.dlock)
    end
end

"""
    empty!(dic::ThreadSafeDict)
    
Remove all keys and values from the Dict
"""
function empty!(dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        empty!(dic.d)
    finally
        unlock(dic.dlock)
    end
end

"""
    delete!(dic::ThreadSafeDict, k)
    
delete key k and its value from the dict
"""
function delete!(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        delete!(dic.d, k)
    finally
        unlock(dic.dlock)
    end
end

"""
    length(dic::ThreadSafeDict)
    
Return the length of the Dict, considered as a vector of key-value pairs
"""
function length(dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        length(dic.d)
    finally
        unlock(dic.dlock)
    end
end

"""
    iterate(dic::ThreadSafeDict)
    
Iterate through the Dict returning its key-value pairs.
"""
function iterate(dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        d = collect(dic.d)
        p = iterate(d)
        p === nothing ? nothing : (p[1], (d, p[2]))
    finally
        unlock(dic.dlock)
    end
end

"""
    iterate(dic::ThreadSafeDict, i)
    
Iterate through the Dict returning its key-value pairs.
"""
function iterate(dic::ThreadSafeDict, i)
    d, state = i
    p = iterate(d, state)
    p === nothing ? nothing : (p[1], (d, p[2]))
end

"""
    print(io::IO, dic::ThreadSafeDict)
    
Print the ThreadSafeDict, including the state of its lock and contents of the undelying Dict.
"""
function print(io::IO, dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        print(io, "Dict was locked, contents: ", dic.d)
    finally
        unlock(dic.dlock)
    end
end

end # module ThreadSafeDicts
