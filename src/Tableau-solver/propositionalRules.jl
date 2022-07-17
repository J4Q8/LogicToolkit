function negDis!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add resulting formulas to the current branch (list)
            and will set the "applied" flag of the original formula to true
    =#

    t = tableau.list[idx]
    formula = t.formula.right

    # rule for ¬∨
    f1 = Tree('¬')
    addrightchild!(f1, formula.left)
    addFormula!(tableau, f1, t.world)

    appliedwhere = length(tableau.list)

    f2 = Tree('¬')
    addrightchild!(f2, formula.right)
    addFormula!(tableau, f2, t.world)

    tableau.applied[idx] = appliedwhere
end

function negNeg!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add resulting formulas to the current branch (list)
            and will set the "applied" flag of the original formula to true
    =#

    t = tableau.list[idx]
    formula = t.formula.right

    # rule for ¬¬
    addFormula!(tableau, formula.right, t.world)
    appliedwhere = length(tableau.list)

    tableau.applied[idx] = appliedwhere
end

function con!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add resulting formulas to the current branch (list)
            and will set the "applied" flag of the original formula to true
    =#
    t = tableau.list[idx]
    formula = t.formula

    # rule for ∧
    addFormula!(tableau, formula.left, t.world)
    appliedwhere = length(tableau.list)

    addFormula!(tableau, formula.right, t.world)

    tableau.applied[idx] = appliedwhere
end

function negImp!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add resulting formulas to the current branch (list)
            and will set the "applied" flag of the original formula to true
    =#

    t = tableau.list[idx]
    formula = t.formula.right

    # rule for ¬→
    addFormula!(tableau, formula.left, t.world)
    appliedwhere = length(tableau.list)

    f2 = Tree('¬')
    addrightchild!(f2, formula.right)
    addFormula!(tableau, f2, t.world)

    tableau.applied[idx] = appliedwhere
end

function negCon!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add one of the resulting formulas to the current branch (list),
            add the other resulting formula to a stack of branches along with its desired line number
            and will set the "applied" flag of the original formula to true
    =#
    t = tableau.list[idx]
    formula = t.formula.right

    # rule for ¬∧
    f1 = Tree('¬')
    addrightchild!(f1, formula.left)
    addFormula!(tableau, f1, t.world)
    appliedwhere = length(tableau.list)

    f2 = Tree('¬')
    addrightchild!(f2, formula.right)
    tuple2 = (formula = f2, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple2)

    tableau.applied[idx] = appliedwhere
end

function dis!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add one of the resulting formulas to the current branch (list),
            add the other resulting formula to a stack of branches along with its desired line number
            and will set the "applied" flag of the original formula to true
    =#
    t = tableau.list[idx]
    formula = t.formula

    # rule for ∨
    addFormula!(tableau, formula.left, t.world)
    appliedwhere = length(tableau.list)

    tuple2 = (formula = formula.right, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple2)
    
    tableau.applied[idx] = appliedwhere
end

function imp!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add one of the resulting formulas to the current branch (list),
            add the other resulting formula to a stack of branches along with its desired line number
            and will set the "applied" flag of the original formula to true
    =#
    t = tableau.list[idx]
    formula = t.formula

    # rule for →
    f1 = Tree('¬')
    addrightchild!(f1, formula.left)
    addFormula!(tableau, f1, t.world)
    appliedwhere = length(tableau.list)

    tuple2 = (formula = formula.right, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple2)

    tableau.applied[idx] = appliedwhere
end

function biImp!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add two of the resulting formulas to the current branch (list),
            add the other two resulting formula to a stack of branches along with its desired line number 
            (both of them will be given the same line number)
            and will set the "applied" flag of the original formula to true
    =#

    t = tableau.list[idx]
    formula = t.formula

    # rule for ↔
    addFormula!(tableau, formula.left, t.world)
    appliedwhere = length(tableau.list)

    f1 = Tree('¬')
    addrightchild!(f1, formula.left)
    tuple1 = (formula = f1, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple1)

    f2 = Tree('¬')
    addrightchild!(f2, formula.right)
    tuple2 = (formula = f2, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple2)  

    addFormula!(tableau, formula.right, t.world)  

    tableau.applied[idx] = appliedwhere
end

function negBiImp!(tableau::Tableau, idx::Int64)
    #=
        tableau:    takes a current tableau
        idx:        takes an index of formula to which we apply this rule

        This function will add two of the resulting formulas to the current branch (list),
            add the other two resulting formula to a stack of branches along with its desired line number 
            (both of them will be given the same line number)
            and will set the "applied" flag of the original formula to true
    =#

    t = tableau.list[idx]
    formula = t.formula.right

    # rule for ¬↔
    addFormula!(tableau, formula.left, t.world)
    appliedwhere = length(tableau.list)
    
    f1 = Tree('¬')
    addrightchild!(f1, formula.left)
    tuple1 = (formula = f1, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple1)   

    tuple2 = (formula = formula.right, world = t.world, line = appliedwhere)
    push!(tableau.branches, tuple2)

    f3 = Tree('¬')
    addrightchild!(f3, formula.right)
    addFormula!(tableau, f3, t.world)

    tableau.applied[idx] = appliedwhere
end