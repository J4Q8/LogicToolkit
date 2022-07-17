CONNECTIVES = ['∧', '→', '↔', '∨']
MODALS = ['◇', '◻']
NEG = ['¬']
ATOMS = ['p','q', '⊥','⊤']

function getBanned(connective::Char)
    if connective == '∧'
        return ['⊥','⊤'], ['⊥','⊤']
    elseif connective == '→'
        return ['⊥'], ['⊤']
    elseif connective == '↔'
        return Char[], Char[]
    elseif connective == '∨'
        return ['⊥','⊤'], ['⊥','⊤']
    else
        return Char[], Char[]
    end
end

function generateFormulaTrivial(depth::Int64, modal::Int64, banned::Vector{Char} = ATOMS)

    if depth == 1
        choice = sample(ATOMS)
        leaf = Tree(choice)
        return leaf 
    else
        possible = [CONNECTIVES; ATOMS]
        possible = [possible; NEG]
        if modal > 0
            possible = [possible; MODALS]
        end
        setdiff!(possible, banned)
        choice = sample(possible)
        root = Tree(choice)
        if choice in NEG
            # neg does not reset the modal depth, neg T and neg F do not make sense
            child1 = generateFormula(depth-1, modal, true, Char[])
            addrightchild!(root, child1)
            return root
        elseif choice in MODALS
            child1 = generateFormula(depth-1, modal-1, false, Char[])
            addrightchild!(root, child1)
            return root
        elseif choice in CONNECTIVES
            child1 = generateFormula(depth-1, modal, false, Char[])
            child2 = generateFormula(depth-1, modal, false, Char[])
            addleftchild!(root, child1)
            addrightchild!(root, child2)
            return root
        else
            leaf = Tree(choice)
            return leaf
        end
    end
end

function generateFormula(depth::Int64, modal::Int64, prevNeg::Bool, banned::Vector{Char} = ATOMS)

    if depth == 1
        choice = sample(ATOMS)
        leaf = Tree(choice)
        return leaf 
    else
        possible = [CONNECTIVES; ATOMS]
        if !prevNeg
            possible = [possible; NEG]
        end
        if modal > 0
            possible = [possible; MODALS]
        end
        setdiff!(possible, banned)
        choice = sample(possible)
        root = Tree(choice)
        if choice in NEG
            # neg does not reset the modal depth, neg T and neg F do not make sense
            child1 = generateFormula(depth-1, modal, true, ['⊥','⊤'])
            addrightchild!(root, child1)
            return simplify(root)
        elseif choice in MODALS
            child1 = generateFormula(depth-1, modal-1, false, Char[])
            addrightchild!(root, child1)
            return simplify(root)
        elseif choice in CONNECTIVES
            leftban, rightban = getBanned(choice)
            child1 = generateFormula(depth-1, modal, false, leftban)
            child2 = generateFormula(depth-1, modal, false, rightban)
            while isEquivalent(child1, child2)
                child2 = generateFormula(depth-1, modal, false, rightban)
            end
            addleftchild!(root, child1)
            addrightchild!(root, child2)
            return simplify(root)
        else
            leaf = Tree(choice)
            return leaf
        end
    end
end

function generateFormulaOfDepth(depth::Int64, maxConseqModal::Int64, nonTrivial::Bool = true)
    while true
        if nonTrivial
            f = generateFormula(depth, maxConseqModal, false)
        else
            f = generateFormulaTrivial(depth, maxConseqModal, false)
        end

        if height(f) >= depth
            return f
        end
    end
end

function generateFormulas(number::Int64, depth::Int64, maxModalDepth::Int64, nonTrivial::Bool)
    formulas = Tree[]
    for n in 1:number
        formula = generateFormulaOfDepth(depth, maxModalDepth, nonTrivial)
        while formula ∈ formulas
            formula = generateFormulaOfDepth(depth, maxModalDepth, nonTrivial)
        end
        push!(formulas, formula)
    end
end