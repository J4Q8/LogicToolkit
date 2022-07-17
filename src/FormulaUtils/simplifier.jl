function isIn(formula::Tree, list::Vector{Tree})
    for l in list
        if isEquivalent(formula, l)
            return true
        end
    end
    return false
end

function simplifyChildren(formula::Tree)
    connective = Tree(formula.connective)
    if isdefined(formula, :left)
        addleftchild!(connective, simplify(formula.left))
    end
    if isdefined(formula, :right)
        addrightchild!(connective, simplify(formula.right))
    end
    return connective
end

function anyOppositeFormulas(juncts::Vector{Tree})
    for (idx, junct1) in enumerate(juncts[1:end-1])
        for junct2 in juncts[idx+1:end]
            if isOppositeEqui(junct1, junct2)
                return true
            end
        end
    end
    return false
end

function rebuildTreeFromJuncts(connective::Char, juncts::Vector{Tree})
    if length(juncts) == 1
        return juncts[1]
    elseif length(juncts) > 1
        root = Tree(connective)
        addleftchild!(root, juncts[1])
        addrightchild!(root, rebuildTreeFromJuncts(connective, juncts[2:end]))
        return root
    else
        throw(DomainError(juncts, "This should never be empty"))
    end
end

function getRepeatingJuncts(juncts::Vector{Tree})
    repeating = Vector{Int64}[]
    for (idx1, junct1) in enumerate(juncts[1:end-1])
        for (idx2, junct2) in enumerate(juncts[idx1+1:end])
            if isEquivalent(junct1, junct2)
                #add to list of repeating formulas
                added = false
                for r in repeating
                    if idx1 ∈ r 
                        added = true
                        if idx1+idx2 ∉ r
                            push!(r, idx1+idx2)
                        end
                    end
                end
                if !added
                    push!(repeating, [idx1, idx1+idx2])  
                end              
            end
        end
    end
    return repeating
end

function reduceRepeatingJuncts(connective::Char, juncts::Vector{Tree})
    repeating = getRepeatingJuncts(juncts)
    # remove repeating formulas
    toDelete = Int64[]
    for r in repeating
        toDelete = [toDelete; r[2:end]]
    end
    deleteat!(juncts, sort(toDelete))

    idx2Remove = Int64[]
    for (idx, junct) in enumerate(juncts)
        if connective == '∧' && isEquivalent(junct, Tree('⊤'))
            push!(idx2Remove, idx)
        elseif connective == '∨' && isEquivalent(junct, Tree('⊥'))
            push!(idx2Remove, idx)
        end
    end
    deleteat!(juncts, idx2Remove)

    if length(juncts) == 0
        if connective == '∧'
            push!(juncts, Tree('⊤'))
        elseif connective == '∨'
            push!(juncts, Tree('⊥'))
        end
    end
    # recreate tree structure using juncts
    return rebuildTreeFromJuncts(connective, juncts)
end

function replaceRepeatingJunctsWithT(juncts::Vector{Tree})
    repeating = getRepeatingJuncts(juncts)
    
    vcat(repeating...)
    idx2Remove = Int64[]
    for r in repeating
        if iseven(length(r))
            idx2Remove = [idx2Remove; r]
        else
            idx2Remove = [idx2Remove; r[2:end]]
        end    
    end
    deleteat!(juncts, sort(idx2Remove))
    # for biconditional we can rearrange juncts in a way that all repeating elements will be next to each other
    # then all repeating formulas of the same time can be replaced with 'T'
    # if there is more than 1 repeating formula then we can still replace it with just one 'T', 
    # because we can rearrange them into (T <-> T) <-> T, which is T
    if !isIn(Tree('⊤'), juncts)  && length(idx2Remove) != 0
        push!(juncts, Tree('⊤'))
    end

    return juncts
end

function getOppositeJuncts(juncts::Vector{Tree})
    opposite = Vector{Int64}[]
    for (idx1, junct1) in enumerate(juncts[1:end-1])
        for (idx2, junct2) in enumerate(juncts[idx1+1:end])
            if isOppositeEqui(junct1, junct2)
                #add to list of repeating formulas
                push!(opposite, [idx1, idx1+idx2])        
            end
        end
    end
    return opposite
end

function replaceOppositeJunctsWithF(juncts::Vector{Tree})
    opposite = getOppositeJuncts(juncts)

    #flatten array
    flatten = vcat(opposite...)

    if flatten != unique(flatten)
        throw(ErrorException("This should never happen, call replace repeating juncts with T before"))
    end

    falseCount = length(flatten)
    deleteat!(juncts, sort(flatten))
    
    if iseven(falseCount) && falseCount != 0
        if !isIn(Tree('⊥'), juncts)
            push!(juncts, Tree('⊥'))
        else
            push!(juncts, Tree('⊤'))
        end
    else
        # add T if it already isn't in the juncts
        if !isIn(Tree('⊤'), juncts)
            push!(juncts, Tree('⊤'))
        end
    end
    return juncts
end

function simplifyConj(formula::Tree)

    juncts = getJuncts(formula, formula.connective)

    if formula.left.connective == '⊥' || formula.right.connective == '⊥' || anyOppositeFormulas(juncts)
        return Tree('⊥')
    end

    reducedFormula = reduceRepeatingJuncts(formula.connective, juncts)
    return simplifyChildren(reducedFormula)
end

function simplifyDisj(formula::Tree)
    
    juncts = getJuncts(formula, formula.connective)

    if formula.left.connective == '⊤' || formula.right.connective == '⊤' || anyOppositeFormulas(juncts)
        return Tree('⊤')
    end

    reducedFormula = reduceRepeatingJuncts(formula.connective, juncts)
    return simplifyChildren(reducedFormula)
end

function simplifyImp(formula::Tree)
    if formula.left.connective == '⊥'
        return Tree('⊤') 
    elseif formula.right.connective == '⊤'
        return Tree('⊤')
    elseif formula.left.connective == '⊤' && formula.right.connective == '⊥'
        return Tree('⊥') 
    elseif formula.left.connective == '⊤'
        return formula.right
    elseif formula.right.connective == '⊥'
        root = Tree('¬')
        addrightchild!(root, formula.left)
        return root
    else
        return simplifyChildren(formula)
    end
end

function simplifyBiImp(formula::Tree)
    # first reduce repeating then opposite
    if formula.left.connective == '⊥'
        root = Tree('¬')
        addrightchild!(root, formula.right)
        return root
    elseif formula.right.connective == '⊥'
        root = Tree('¬')
        addrightchild!(root, formula.left)
        return root
    elseif formula.left.connective == '⊤'
        return formula.right
    elseif formula.right.connective == '⊤'
        return formula.left
    else
        juncts = getJuncts(formula, formula.connective)
        juncts = replaceRepeatingJunctsWithT(juncts)
        juncts = replaceOppositeJunctsWithF(juncts)
        reducedFormula = rebuildTreeFromJuncts(formula.connective, juncts)
        return simplifyChildren(reducedFormula)
    end
end

function simplifyNeg(formula::Tree)
    if formula.right.connective == '¬'
        return simplify(formula.right.right)
    elseif formula.right.connective == '◻'
        root = Tree('◇')
        neg = Tree('¬')
        addrightchild!(neg, simplify(formula.right.right))
        addrightchild!(root, neg)
        return root
    elseif formula.right.connective == '◇'
        root = Tree('◻')
        neg = Tree('¬')
        addrightchild!(neg, simplify(formula.right.right))
        addrightchild!(root, neg)
        return root
    elseif formula.right.connective == '⊥'
        Tree('⊤')
    elseif formula.right.connective == '⊤'
        Tree('⊥')
    else
        return simplifyChildren(formula)
    end
end

function simplifyDia(formula::Tree)
    if formula.right.connective == '⊥'
        return Tree('⊥')
    else
        return simplifyChildren(formula)
    end
end

function simplifyBox(formula::Tree)
    if formula.right.connective == '⊤'
        return Tree('⊤')
    else
        return simplifyChildren(formula)
    end
end

function simplifySwitch(formula::Tree)
    if formula.connective == '∧'
        return simplifyConj(formula)
    elseif formula.connective == '→'
        return simplifyImp(formula)
    elseif formula.connective == '↔'
        return simplifyBiImp(formula)
    elseif formula.connective == '∨'
        return simplifyDisj(formula)
    elseif formula.connective == '¬'
        return simplifyNeg(formula)
    elseif formula.connective == '◇'
        return simplifyDia(formula)
    elseif formula.connective == '◻'
        return simplifyBox(formula)
    else
        return formula
    end
end

function simplify(formula::Tree)
    steadystate = deepcopy(formula)
    simplified = simplifySwitch(formula)
    while !isequal(steadystate, simplified)
        steadystate = deepcopy(simplified)
        simplified = simplify(simplified)
    end
    return simplified
end