function applyNonBranching!(tableau::Tableau)
    #=
        Returns true if at least one new rule has been applied
    =#
    flag = false
    for (idx, i) in enumerate(tableau.list)

        if tableau.applied[idx] != 0
            continue
        end

        if i.formula.connective == '∧'
            con!(tableau, idx)
            flag = true
        elseif i.formula.connective == '¬'
            f = i.formula.right
            if f.connective == '∨'
                negDis!(tableau, idx)
                flag = true
            elseif f.connective == '¬'
                negNeg!(tableau, idx)
                flag = true
            elseif f.connective == '→'
                negImp!(tableau, idx)
                flag = true
            end
        end
    end
    return flag
end

function applyModal!(tableau::Tableau, constraints::Vector{Char})
    #=
        Returns true if at least one new rule has been applied
    =#    

    #Alternative rules for the GL due to converse well foundedness
    iswf = 'c' in constraints ? true : false
    d! = iswf ? diaGL! : dia!
    b! = iswf ? boxGL! : box!
    #nd! = iswf ? negDiaGL! : negDia! # I DON' THINK IT IS NECESSARY TO HAVE SPECIAL SHORTCUT RULES FOR GL
    nd! = negDia!
    #nb! = iswf ? negBoxGL! : negBox!
    nb! = negBox!

    flag = false
    for (idx, i) in enumerate(tableau.list)

        if tableau.applied[idx] != 0
            continue
        end

        c = i.formula.connective
        if c == '◇'
            d!(tableau, idx)
            flag = true
        elseif c == '◻'
            b!(tableau, idx)
            flag = true
        elseif c == '¬'
            f = i.formula.right
            if f.connective == '◻'
                nb!(tableau, idx)
                flag = true
            elseif f.connective == '◇'
                nd!(tableau, idx)
                flag = true
            end
        end
    end

    #reflexivity has to be applied even if there are no relations introduced yet
    #if new relations have been added we need to run the algorithm again
    if 'r' in constraints
        flag = reflexivity!(tableau) || flag
    end

    if 't' in constraints
        flag = transitivity!(tableau) || flag
    end

    if 's' in constraints
        flag = symmetry!(tableau) || flag
    end

    return flag
end

function applyBranching!(tableau::Tableau)
    #=
        Returns true if at least one new rule has been applied
    =#

    flag = false
    for (idx, i) in enumerate(tableau.list)

        if tableau.applied[idx] != 0
            continue
        end

        c = i.formula.connective
        if c == '∨'
            dis!(tableau, idx)
            flag = true
        elseif c == '→'
            imp!(tableau, idx)
            flag = true
        elseif c == '↔'
            biImp!(tableau, idx)
            flag = true
        elseif c == '¬'
            f = i.formula.right
            if f.connective == '∧'
                negCon!(tableau, idx)
                flag = true
            elseif f.connective == '↔'
                negBiImp!(tableau, idx)
                flag = true
            end
        end
    end
    return flag
end

function isClosed(list::Vector{NamedTuple{(:formula, :world), Tuple{Tree, Int64}}})
    for i in list
        # stopping criterion in case explicit contradiction is ancountered
        if i.formula.connective == '⊥' || (i.formula.connective == '¬' && i.formula.right.connective == '⊤') 
            return true
        end 
    end
    for (idx, i) in enumerate(list[1:end-1])
        for j in list[idx+1:end]
            if isOpposite(i.formula, j.formula) && i.world == j.world
                return true
            end
        end
    end
    return false
end

function getAllWorlds(tableau::Tableau)
    worlds = Int64[]
    for f in tableau.list 
        if !(f.world in worlds)
            push!(worlds, f.world)
        end
    end
    return worlds
end

function isInfiniteAlpha(tableau::Tableau)
    #after this many worlds are introduced the infinite check will be called
    THRESHOLD = 40

    worlds = getAllWorlds(tableau)

    if length(worlds) > THRESHOLD
        counter = 0
        lastworld = maximum(worlds)
        f2check = Tree[]
        for l in tableau.list
            if l.world == lastworld
                push!(f2check, l.formula)
            end
        end
        for w in worlds
            check = 0
            for f in f2check
                if isOnList(tableau, (formula = f, world = w))
                    check = 1 + check
                else
                    break
                end
            end
            if check == length(f2check)
                counter = 1 + counter
            end
        end
        if counter == THRESHOLD
            return true
        end
    end
    return false
end

function isSubset(list::Set{Tree}, biggerlist::Set{Tree})
    for t in list
        flag = false
        for t2 in biggerlist
            if isequal(t, t2)
                flag = true
            end
        end
        if !flag
            return false
        end
    end
    return true
end

function isInfiniteBeta(tableau::Tableau)
    #after this many worlds are introduced the infinite check will be called

    #make a set of formulas going from the highest number to lowest and when the formulas in a world are already in a set or extend 
    THRESHOLD = 40

    worlds = getAllWorlds(tableau)

    counter = 0
    period = 0
    if length(worlds) > THRESHOLD
        sets = [Set{Tree}([]) for _ in 1:length(worlds)]
        for t in tableau.list
            #worlds start at 0, arrays at 1
            push!(sets[t.world+1], t.formula)
        end

        # detect period of repetitions
        step = 0
        reverse!(sets)
        last = sets[1]
        for s in sets[2:end]
            current = s
            step = step + 1
            if isSubset(last, current)
                period = period + step
                break
            end
        end

        # no repeating elements or the period is equal or larger than half the threshold
        if period < 1 || period >= THRESHOLD/2
            return false
        end

        #check if pattern repeats taking into account the possibily alternating pattern
        for (idx, s) in enumerate(sets[1:end-period])
            if isSubset(s, sets[idx+period])
                counter = counter + 1
            else
                break
            end
        end
    end

    if counter >= THRESHOLD - period
        return true
    else
        return false
    end
end

function isEndWorld(tableau::Tableau, endWorld::Int64)
    for r in tableau.relations
        if r.i == endWorld && r.i != r.j
            return false
        end
    end
    return true
end

function traceBack(tableau::Tableau, endWorld::Int64)
    order = Int64[]
    for r in tableau.relations
        if r.j == endWorld && r.i != r.j && r.i ∉ order
            push!(order, r.i)
        end
    end

    ordercopy = copy(order)
    for w in ordercopy
        order = union(order, traceBack(tableau, w))
    end
    #add the endworld
    push!(order, endWorld)

    return order
end

function getOrders(tableau::Tableau)

    orders = Vector{Int64}[]
    worlds = sort(getAllWorlds(tableau), rev=true)
    endWorlds = Int64[]

    for w in worlds
        if isEndWorld(tableau, w)
            push!(endWorlds, w)
        end
    end

    for e in endWorlds
        order = sort(traceBack(tableau, e), rev=true)
        push!(orders, order)
    end

    return orders
end


function isInfiniteGamma(tableau::Tableau)
    #after this many worlds are introduced the infinite check will be called

    #make a set of formulas going from the highest number to lowest and when the formulas in a world are already in a set or extend 
    THRESHOLD = 10

    worlds = getAllWorlds(tableau)

    repeating = Int64[]

    if length(worlds) > THRESHOLD

        orders = getOrders(tableau)
        lengths = [length(order) for order in orders]
        mean = sum(lengths)/(length(lengths))

        for order in orders
            
            #filter out ones that have probably stopped already
            if length(order) < mean - THRESHOLD
                continue
            end

            sets = [Set{Tree}([]) for _ in 1:length(order)]
            for t in tableau.list
                positionArray = indexin(t.world, order)
                if !(positionArray .== nothing)
                    #worlds start at 0, arrays at 1
                    if t.formula.connective == '◇'
                        push!(sets[positionArray[1]], t.formula)
                    end
                end
            end

            lastOriginal = length(order) # fake infinity
            for (idx, s) in enumerate(sets[1:end-1])
                lastOriginalMainLoop = lastOriginal
                for f in s
                    original = true
                    for s2 in sets[idx+1:end]
                        if isSubset(Set{Tree}([f]), s2)
                            original = false
                            break
                        end
                    end
                    if original
                        lastOriginalMainLoop = minimum([lastOriginalMainLoop, idx])
                    end
                end
                lastOriginal = minimum([lastOriginal, lastOriginalMainLoop])
            end
            push!(repeating, lastOriginal)
        end
    end

    if length(repeating) != 0 && minimum(repeating) >= THRESHOLD/2
        return true
    else
        return false
    end
end

function isInfinite(tableau::Tableau)
    #after this many worlds are introduced the infinite check will be called

    #make a set of formulas going from the highest number to lowest and when the formulas in a world are already in a set or extend 
    THRESHOLD = 100

    worlds = getAllWorlds(tableau)

    lastOriginal = length(worlds)
    if length(worlds) > THRESHOLD

        sets = [Set{Tree}([]) for _ in 1:maximum(worlds)+1]
        for t in tableau.list
            #worlds start at 0 arrays in Julia at 1, hence +1
            push!(sets[t.world+1], t.formula)
        end

        reverse!(sets)

        for (idx, s) in enumerate(sets[1:end-1])
            lastOriginalMainLoop = lastOriginal
            for f in s
                original = true
                for s2 in sets[idx+1:end]
                    if isSubset(Set{Tree}([f]), s2)
                        original = false
                        break
                    end
                end
                if original
                    lastOriginalMainLoop = minimum([lastOriginalMainLoop, idx])
                end
            end
            lastOriginal = minimum([lastOriginal, lastOriginalMainLoop])
        end
    end
    
    #if the last original formula was introduced THRESHOLD worlds ago or more than its repeating
    if lastOriginal >= THRESHOLD
        return true
    else
        return false
    end
end

function isInfPossible(constraints::Vector{Char})
    if 'c' in constraints
        return false
    end
    if 't' in constraints
        return true
    end
    return false
end

function timeLimitExceeded(startTime::UInt64, timeLimit::Int64 = 30) #should be 30 (in sec)
    endTime = time_ns()
    if (endTime - startTime)*1e-9 > timeLimit
        return true
    end
    return false
end

function solveBranch!(tableau::Tableau, constraints::Vector{Char}, startTime::UInt64, mode::Int64 = 1)
    #=
        returns true when the branch is closed and complete, false when the branch is open and complete
    =#
    infPos = isInfPossible(constraints)
    # this loop makes sure that the rules are applied in a correct order as long as there any rules left to be applied
    while true
        if timeLimitExceeded(startTime)
            return false
        end
        if infPos
            if isInfinite(tableau)
                if mode == 1
                    println("Infinite branch!")
                end
                break
            end
            if isClosed(tableau.list) || (!applyNonBranching!(tableau) && (!applyModal!(tableau, constraints) & !applyBranching!(tableau)))
                break
            end
        else
            if isClosed(tableau.list) || (!applyNonBranching!(tableau) && !applyModal!(tableau, constraints) && !applyBranching!(tableau))
                break
            end
        end
    end
    
    return isClosed(tableau.list) 
end

function solve!(tableau::Tableau, constraints::Vector{Char}, mode::Int64 = 1)
    #mode == 1 : print, no return
    #mode == 2 : no print, return

    if 'c' ∈ constraints && 't' ∈ constraints
        deleteat!(constraints, findall(x->x=='t',constraints))
    end
    
    startTime = time_ns()
    while true
        if solveBranch!(tableau, constraints, startTime, mode)
            if length(tableau.branches) != 0

                branch = pop!(tableau.branches)

                # remove irrelevant formulas from the current branch (list)
                # remove formulas after the most recent branching
                while length(tableau.list) >= branch.line
                    _ = pop!(tableau.list)
                    _ = pop!(tableau.applied)
                end
                
                # make sure that all rules that have been applied after branching are applied again on a new branch
                for (i,f) in enumerate(tableau.applied)
                    if f > branch.line
                        tableau.applied[i] = 0
                    end
                end

                # remove relations introduced on the other branch, leave ones on the common part of that branch
                idx2remove = Int64[]
                for (i,r) in enumerate(tableau.relations)
                    if r.line >= branch.line
                        push!(idx2remove,i)
                    end
                end
                deleteat!(tableau.relations, idx2remove)
                
                # while-loop used to accomodate the multiple formulas on a new branch produced by negImp! and imp!
                # we will add all formulas in a new branch to the current branch (list)
                while true
                    addFormula!(tableau, branch.formula, branch.world)
                    if length(tableau.branches) > 0 && tableau.branches[end].line == branch.line
                        branch = pop!(tableau.branches)
                    else
                        break
                    end
                end

                # refresh boxes, because some of the rules might have not been applied because of already exisiting formulas on pther branches
                refreshBox!(tableau)

                # watch out for infipedes
                # printBranch(tableau)
                if isInfPossible(constraints) && isInfinite(tableau) && !isClosed(tableau.list) 
                    if mode == 1
                        println("Infinite branch! Infinipede!")
                    end
                    break
                end

            else
                if mode == 1
                    println("Tableau is closed and complete!")
                    return
                else
                    return true
                end
            end
        else
            if timeLimitExceeded(startTime)
                if mode == 1
                    println("Time limit has been exceeded")
                end
                return nothing
            end
            break
        end
    end
    if mode == 1
        print("Tableau has at least one open and (complete or infinite) branch:\n")
        printBranch(tableau)
    else
        return false
    end
end