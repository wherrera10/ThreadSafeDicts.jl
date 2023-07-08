using Test

using ThreadSafeDicts  # implement a single lock on all shared values as a task Dict

const iddict = ThreadSafeDict{Int, Int}()
flag(id) = get(iddict, id, 0)

const tdict = Dict{Int, Vector{Int}}()
addresult(id) = (tid = Threads.threadid(); tdict[tid] = vcat(get!(tdict, tid, Int[]), id))

""" test the implementation on each thread, concurrently"""
function runSzymański(id, allszy)
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
    addresult(id)
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
    allszy = collect(1:N)
    @Threads.threads for i in eachindex(allszy)
        runSzymański(i, allszy)
    end
    @test 1:N == reduce(vcat, values(tdict)) |> sort!
end

test_Szymański(20000)
