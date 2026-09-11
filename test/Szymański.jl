using Test

using ThreadSafeDicts  # implement a single lock on all shared values as a task Dict

const iddict = ThreadSafeDict{Int, Int}()
flag(id) = get(iddict, id, 0)

""" test the implementation on each thread, concurrently """
function runSzymański(id, allszy, tdict, inside)
    others = filter(!=(id), allszy)
    iddict[id] = 1                            # Standing outside waiting room
    while !all(t -> flag(t) < 3, others)      # Wait for open door
        yield()
    end
    iddict[id] = 3                            # Standing in doorway
    if any(t -> flag(t) == 1, others)         # Another process is waiting to enter
        iddict[id] = 2                        # Waiting for other processes to enter
        while !any(t -> flag(t) == 4, others) # Wait for a process to enter and close the door
            yield()
        end
    end
    iddict[id] = 4                            # The door is closed
    for t in others                           # Wait for everyone of lower ID to finish exit 
        t >= id && continue
        while flag(t) > 1
            yield()
        end
    end

    # critical section
    Threads.atomic_add!(inside, 1)
    @test inside[] == 1
    tid = Threads.threadid()
    tdict[tid] = vcat(get!(tdict, tid, Int[]), id)
    Threads.atomic_add!(inside, -1)
    id % 100 == 0 && print(id, "...\b\b\b\b\b\b\b\b\b")
    # end critical section

    # Exit protocol
    for t in others                           # Ensure everyone in the waiting room has
        t <= id && continue
        while flag(t) ∉ [0, 1, 4]             # realized that the door is supposed to be closed

            yield()
        end
    end
    iddict[id] = 0                            # Leave. Reopen door if nobody is still in the waiting room
end

function test_Szymański(N)
    empty!(iddict)
    tdict = Dict{Int, Vector{Int}}()
    inside = Threads.Atomic{Int}(0)
    allszy = collect(1:N)
    @Threads.threads for i in eachindex(allszy)
        runSzymański(i, allszy, tdict, inside)
    end
    @test inside[] == 0
    @test 1:N == reduce(vcat, values(tdict)) |> sort!
end

test_Szymański(2000)

true
