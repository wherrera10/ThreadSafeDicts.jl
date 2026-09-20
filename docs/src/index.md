# ThreadSafeDicts.jl
A thread-safe `Dict` type for Julia programming

![Description](assets/spool.png)

## Struct and Constructors

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
```

Struct and constructors for ThreadSafeDict. There is one private ReentrantLock per Dict struct. All functions lock this lock, pass
arguments to the d member Dict, unlock the ReentrantLock, and then return what is returned by the Dict.

## Installation
```julia
using Pkg
Pkg.add("ThreadSafeDicts")
```

## Functions Reference


```@index
```

```@autodocs
Modules = [ThreadSafeDicts]
```
