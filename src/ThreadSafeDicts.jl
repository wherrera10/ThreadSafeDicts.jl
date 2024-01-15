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
    dlock::Threads.SpinLock
    d::Dict{K, V}
    ThreadSafeDict{K, V}() where V where K = new(Threads.SpinLock(), Dict{K, V}())
    ThreadSafeDict{K, V}(itr) where V where K = new(Threads.SpinLock(), Dict{K, V}(itr))
end
ThreadSafeDict() = ThreadSafeDict{Any,Any}()
ThreadSafeDict(itr) = ThreadSafeDict{Any, Any}(itr) # for issue #12

"""
    getindex(dic::ThreadSafeDict, k)
    
Get the value at key index k.
"""
function getindex(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        v = getindex(dic.d, k)
        unlock(dic.dlock)
        return v
    catch
        unlock(dic.dlock)
        rethrow()
    end
end

"""
    setindex!(dic::ThreadSafeDict, k, v)
    
Set the value at key index k to v.
"""
function setindex!(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    try
        h = setindex!(dic.d, k, v)
        unlock(dic.dlock)
        return h
    catch
        unlock(dic.dlock)
        rethrow()
    end
end

"""
    haskey(dic::ThreadSafeDict, k)

Return true if key k is in the dict, else return false.
"""
function haskey(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    b = haskey(dic.d, k)
    unlock(dic.dlock)
    return b
end

"""
    get(dic::ThreadSafeDict, k, v)
    
Get value at key k if exists, otherwise return v
"""
function get(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    v = get(dic.d, k, v)
    unlock(dic.dlock)
    return v
end

"""
    get(f::Function, dic::ThreadSafeDict, k)
    
Get value at key k if exists, otherwise return f()
"""
function get(f::Function, dic::ThreadSafeDict, k)
    lock(dic.dlock)
    try
        v = haskey(dic.d, k) ? dic.d[k] : f()
        unlock(dic.dlock)
        return v
    catch
        unlock(dic.dlock)
        rethrow()
    end
end

"""
    get!(dic::ThreadSafeDict, k, v)
    
Get value at key k if exists, otherwise set value at k to v and return v.
"""
function get!(dic::ThreadSafeDict, k, v)
    lock(dic.dlock)
    try
        v = get!(dic.d, k, v)
        unlock(dic.dlock)
        return v
    catch
        unlock(dic.dlock)
        rethrow()
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
            v = dic.d[k]
            unlock(dic.dlock)
            return v
        else
            v = f()
            dic.d[k] = v
            unlock(dic.dlock)
            return v
        end
    catch
        unlock(dic.dlock)
        rethrow()
    end
end
    
"""
    pop!(dic::ThreadSafeDict)
    
remove and return a key-value pair from the Dict
"""
function pop!(dic::ThreadSafeDict)
    lock(dic.dlock)
    try
        p = pop!(dic.d)
        unlock(dic.dlock)
        return p
    catch
        unlock(dic.dlock)
        rethrow()
    end
end

"""
    empty!(dic::ThreadSafeDict)
    
Remove all keys and values from the Dict
"""
function empty!(dic::ThreadSafeDict)
    lock(dic.dlock)
    d = empty!(dic.d)
    unlock(dic.dlock)
    return d
end

"""
    delete!(dic::ThreadSafeDict, k)
    
delete key k and its value from the dict
"""
function delete!(dic::ThreadSafeDict, k)
    lock(dic.dlock)
    p = delete!(dic.d, k)
    unlock(dic.dlock)
    return p
end

"""
    length(dic::ThreadSafeDict)
    
Return the length of the Dict, considered as a vector of key-value pairs
"""
function length(dic::ThreadSafeDict)
    lock(dic.dlock)
    len = length(dic.d)
    unlock(dic.dlock)
    return len
end

"""
    iterate(dic::ThreadSafeDict)
    
Iterate through the Dict returning its key-value pairs. Note order might vary, even between runs of same contents.
"""
function iterate(dic::ThreadSafeDict)
    lock(dic.dlock)
    p = iterate(dic.d)
    unlock(dic.dlock)
    return p
end

"""
    iterate(dic::ThreadSafeDict, i)
    
Iterate through the Dict returning its key-value pairs. Note order might vary, even between runs of same contents.
"""
function iterate(dic::ThreadSafeDict, i)
    lock(dic.dlock)
    p = iterate(dic.d, i)
    unlock(dic.dlock)
    return p
end  

"""
    print(io::IO, dic::ThreadSafeDict)
    
Print the ThreadSafeDict, including the state of its lock and contents of the undelying Dict.
"""
function print(io::IO, dic::ThreadSafeDict)
    print(io, "Dict was ", islocked(dic.dlock) ? "locked" : "unlocked", ", contents: ")
    lock(dic.dlock)
    try
        print(io, dic.d)
        unlock(dic.dlock)
    catch
        unlock(dic.dlock)
        rethrow()
    end
end

end # module
