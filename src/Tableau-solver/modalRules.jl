function firstEmptyWorld(tableau::Tableau)
    max = 0
    for i in tableau.relations
        new_max = maximum([i.i, i.j])
        if new_max > max
            max = new_max
        end
    end
    return max + 1
end

function refreshBox!(tableau::Tableau)
    for (idx, i) in enumerate(tableau.list)
        if i.formula.connective == '◻'
            tableau.applied[idx] = 0
        end
    end
end

function isOnList(tableau::Tableau, t::NamedTuple{(:formula, :world), Tuple{Tree, Int64}})
    for i in tableau.list
        if isequal(t.formula,i.formula) && t.world == i.world
            return true
        end
    end
    return false
end


function isInRelations!(tableau::Tableau, relation::NamedTuple{(:i, :j, :line), Tuple{Int64, Int64, Int64}})
    for r in tableau.relations
        if r.i == relation.i && r.j == relation.j

            # check if the line of the new relation is smaller than the one that is currently on relation list, 
            # if that is the case replace
            if r.line > relation.line
                replace!(tableau.relations, r => relation)
            end
            return true
        end
    end
    return false
end

function dia!(tableau::Tableau, idx::Int64)
    t = tableau.list[idx]
    formula = t.formula

    # rule for ◇
    j = firstEmptyWorld(tableau)
    relation = (i = t.world, j = j, line = idx)
    push!(tableau.relations, relation)

    addFormula!(tableau, formula.right, j)
    appliedwhere = length(tableau.list)

    #mark this rule as applied and make sure all boxes are checked for the new relations
    tableau.applied[idx] = appliedwhere
    refreshBox!(tableau)
end

function box!(tableau::Tableau, idx::Int64)
    #here applied indicates the last application
    t = tableau.list[idx]
    formula = t.formula
    appliedwhere = idx

    # rule for '◻'
    for i in tableau.relations
        if t.world == i.i
            tuple1 = (formula = formula.right, world = i.j)
            if !isOnList(tableau, tuple1)
                push!(tableau.list, tuple1)
                push!(tableau.applied, 0)
                appliedwhere = length(tableau.list)
            end
        end
    end
    #not applied to anything, -1 to indicate that it has been checked
    appliedwhere = appliedwhere == idx ? -1 : appliedwhere
    tableau.applied[idx] = appliedwhere
end

function negDia!(tableau::Tableau, idx::Int64)
    t = tableau.list[idx]
    formula = t.formula.right.right

    f1 = Tree('◻')
    f2 = Tree('¬')
    addrightchild!(f2, formula)
    addrightchild!(f1,f2)
    addFormula!(tableau, f1, t.world)
    appliedwhere = length(tableau.list)
    
    tableau.applied[idx] = appliedwhere
end

function negBox!(tableau::Tableau, idx::Int64)
    t = tableau.list[idx]
    formula = t.formula.right.right

    f1 = Tree('◇')
    f2 = Tree('¬')
    addrightchild!(f2, formula)
    addrightchild!(f1,f2)
    addFormula!(tableau, f1, t.world)
    appliedwhere = length(tableau.list)

    tableau.applied[idx] = appliedwhere
end

function diaGL!(tableau::Tableau, idx::Int64)
    t = tableau.list[idx]
    formula = t.formula

    # rule for ◇ for GL
    j = firstEmptyWorld(tableau)
    relation = (i = t.world, j = j, line = idx)
    push!(tableau.relations, relation)

    f1 = Tree('¬')
    f2 = Tree('◇')
    addrightchild!(f2, formula.right)
    addrightchild!(f1,f2)
    addFormula!(tableau, f1, j)
    appliedwhere = length(tableau.list)
    addFormula!(tableau, formula.right, j)

    #mark this rule as applied and make sure all boxes are checked for the new relations
    tableau.applied[idx] = appliedwhere
    refreshBox!(tableau)
end

function boxGL!(tableau::Tableau, idx::Int64)

    #here the applied indicates the last application of the rule

    t = tableau.list[idx]
    formula = t.formula

    appliedwhere = idx
    
    # rule for '◻' for GL
    for i in tableau.relations
        if t.world == i.i

            f1 = Tree('◻')
            addrightchild!(f1, formula.right)
            tuple1 = (formula = f1, world = i.j)
            tuple2 = (formula = formula.right, world = i.j)

            if !isOnList(tableau, tuple1) && !isOnList(tableau, tuple2)
                push!(tableau.list, tuple1)
                push!(tableau.applied, 0)
                push!(tableau.list, tuple2)
                push!(tableau.applied, 0)
                appliedwhere = length(tableau.list)

            end
        end
    end
    #not applied to anything, -1 to indicate that it has been checked
    appliedwhere = appliedwhere == idx ? -1 : appliedwhere
    tableau.applied[idx] = appliedwhere
end

function transitivity!(tableau::Tableau)
    flag = false
    for (idx, l) in enumerate(tableau.relations)
        #I have to use the this case instead of slicing to be able to use dynamic arrays
        if idx > length(tableau.relations) -1
            continue
        end

        for (idx2, k) in enumerate(tableau.relations)
             #I have to use the this case instead of slicing to be able to use dynamic arrays
            if idx2 <= idx
                continue
            end

            if l.j == k.i
                relation = (i = l.i, j = k.j, line = maximum([l.line, k.line]))
                
                if !isInRelations!(tableau, relation)
                    push!(tableau.relations, relation)
                    flag = true
                end
            end

            #in cases such as 1r0, 0r1
            if l.i == k.j
                relation = (i = k.i, j = l.j, line = maximum([l.line, k.line]))
                
                
                if !isInRelations!(tableau, relation)
                    push!(tableau.relations, relation)
                    flag = true
                end
            end
        end
    end
    if flag
        refreshBox!(tableau)
    end
    return flag
end

function reflexivity!(tableau::Tableau)
    worlds = []
    flag = false
    for (idx, l) in enumerate(tableau.list)
        if !(l.world in worlds)
            push!(worlds, l.world)
            relation = (i = l.world, j = l.world, line = idx)
            #if !(relation in tableau.relations)
            if !isInRelations!(tableau, relation)
                push!(tableau.relations, relation)
                flag = true
            end
        end
    end
    if flag 
        refreshBox!(tableau)
    end
    return flag
end

function symmetry!(tableau::Tableau)
    flag = false
    for r in tableau.relations
        relation = (i = r.j, j = r.i, line = r.line)
        #if !(relation in tableau.relations)
        if !isInRelations!(tableau, relation)
            push!(tableau.relations, relation)
            flag = true
        end
    end
    if flag 
        refreshBox!(tableau)
    end
    return flag
end