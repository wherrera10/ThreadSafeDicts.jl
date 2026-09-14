using Test
using ThreadSafeDicts

const iddict = ThreadSafeDict{Int,Int}()

""" test the implementation on each thread, concurrently """
function runSzymański(id, N, inside, violations, results, threadids)
    flag(id) = get(iddict, id, 0)

    iddict[id] = 1                         # Standing outside waiting room

    while any(t -> t != id && flag(t) >= 3, 1:N)
        yield()                            # Wait for open door
    end

    iddict[id] = 3                         # Standing in doorway

    if any(t -> t != id && flag(t) == 1, 1:N)
        iddict[id] = 2                     # Waiting for other processes to enter

        while !any(t -> t != id && flag(t) == 4, 1:N)
            yield()                        # Wait for a process to enter and close the door
        end
    end

    iddict[id] = 4                         # The door is closed

    for t in 1:N                           # Wait for everyone of lower ID to finish exit
        t >= id && continue

        while flag(t) > 1
            yield()
        end
    end

    # critical section
    old = Threads.atomic_add!(inside, 1)
    old != 0 && Threads.atomic_add!(violations, 1)

    results[id] = true
    threadids[id] = Threads.threadid()

    id % 100 == 0 && print(id, "...\b\b\b\b\b\b\b\b\b")

    Threads.atomic_add!(inside, -1)

    # end critical section

    # Exit protocol
    for t in 1:N                           # Ensure everyone in the waiting room has
        t <= id && continue                # realized that the door is supposed to be closed

        while true
            x = flag(t)
            (x == 0 || x == 1 || x == 4) && break
            yield()
        end
    end

    iddict[id] = 0                         # Leave. Reopen door if nobody is still in the waiting room
end

function test_Szymański(N)
    empty!(iddict)

    inside = Threads.Atomic{Int}(0)
    violations = Threads.Atomic{Int}(0)
    results = falses(N)
    threadids = Vector{Int}(undef, N)

    Threads.@threads for id in 1:N
        runSzymański(id, N, inside, violations, results, threadids)
    end

    println()

    @test inside[] == 0
    @test violations[] == 0
    @test all(results)
    @test all(>(0), threadids)
end

test_Szymański(2000)

true
