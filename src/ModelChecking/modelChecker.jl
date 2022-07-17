TESTMODE = false

function checkTF(t::Tree)
    if t.connective in ['⊤','⊥'] && isdefined(t, :left) && isdefined(t, :right)
        error("This should be a leaf but is:", t)
    end
end

function simplifyInWorldRec(world::Dict{Tree, Bool}, formula::Tree)
    if TESTMODE
        checkTF(formula)
    end

    if haskey(world, formula)
        symbol = world[formula] ? '⊤' : '⊥'
        return Tree(symbol)
    elseif formula.connective ∉ ['◻', '◇']
        root = Tree(formula.connective)
        if isdefined(formula, :left)
            addleftchild!(root, simplifyInWorldRec(world, formula.left))
        end
        if isdefined(formula, :right)
            addrightchild!(root, simplifyInWorldRec(world, formula.right))
        end
        return root
    else
        return formula
    end
end

function simplifyInWorld(world::Dict{Tree, Bool}, formula::Tree)
    formula = simplifyInWorldRec(world, formula)
    return simplify(formula)
end

function cacheFormula!(model::Structure, formula::Tree, world::Int64, result::Bool)
    # IMPORTANT
    # we cache only the children, because the top most formula is never checked again in the same world
    model.worlds[world][formula] = result
end

function checkConj!(model::Structure, formula::Tree, world::Int64)
    # short circuited OR implemented manually (needed to save the formulas)
    lh = checkFormula!(model, formula.left, world)
    cacheFormula!(model, formula.left, world, lh)
    if lh
        return true
    else
        rh = checkFormula!(model, formula.right, world)
        cacheFormula!(model, formula.right, world, rh)
        return rh
    end
end

function checkDisj!(model::Structure, formula::Tree, world::Int64)
    lh = checkFormula!(model, formula.left, world)
    cacheFormula!(model, formula.left, world, lh)
    if !lh
        return false
    else
        rh = checkFormula!(model, formula.right, world)
        cacheFormula!(model, formula.right, world, rh)
        return rh
    end
end

function checkImp!(model::Structure, formula::Tree, world::Int64)
    lh = checkFormula!(model, formula.left, world)
    cacheFormula!(model, formula.left, world, lh)

    rh = checkFormula!(model, formula.right, world)
    cacheFormula!(model, formula.right, world, rh)

    if !lh || rh
        return true
    else
        return false
    end
end

function checkBiImp!(model::Structure, formula::Tree, world::Int64)
    lh = checkFormula!(model, formula.left, world)
    cacheFormula!(model, formula.left, world, lh)
    rh = checkFormula!(model, formula.right, world)
    cacheFormula!(model, formula.right, world, rh)
    if lh == rh
        return true
    else
        return false
    end
end

function checkNeg!(model::Structure, formula::Tree, world::Int64)
    rh = checkFormula!(model, formula.right, world)
    cacheFormula!(model, formula.right, world, rh)
    return !rh
end


function checkDia!(model::Structure, formula::Tree, world::Int64)

    for neighbor in neighbors(model.frame, world)
        if checkFormula!(model, formula.right, neighbor)
            cacheFormula!(model, formula.right, neighbor, true)
            return true
        else
            cacheFormula!(model, formula.right, neighbor, false)
        end
    end

    return false
end

function checkBox!(model::Structure, formula::Tree, world::Int64)

    for neighbor in neighbors(model.frame, world)
        if !checkFormula!(model, formula.right, neighbor)
            cacheFormula!(model, formula.right, neighbor, false)
            return false
        else
            cacheFormula!(model, formula.right, neighbor, true)
        end
    end

    return true
end


function checkFormula!(model::Structure, formula::Tree, world::Int64)
    formula = simplifyInWorld(model.worlds[world], formula)
    if formula.connective == '∨'
        return checkConj!(model, formula, world)
    elseif formula.connective == '∧'
        return checkDisj!(model, formula, world)
    elseif formula.connective == '→'
        return checkImp!(model, formula, world)
    elseif formula.connective == '↔'
        return checkBiImp!(model, formula, world)
    elseif formula.connective == '¬'
        return checkNeg!(model, formula, world)
    elseif formula.connective == '◇'
        return checkDia!(model, formula, world)
    elseif formula.connective == '◻'
        return checkBox!(model, formula, world)
    elseif formula.connective == '⊤'
        return true
    elseif formula.connective == '⊥'
        return false
    end
    error("You reached the end of the switch statement. You shouldn't be here.\n Atoms should have been replaced with their valuations before, however we got: ", formula)
end

function checkModelValidity!(model::Structure, formula::Tree)
    # we decided to iterate from the end because especially for KR frames it will find invalid worlds quicker
    for world in length(model.worlds):-1:1
        if !checkFormula!(model, formula, world)
            return false
        end
    end
    return true
end

function checkFrameValidity(model::Structure, formula::Tree, nValuations::Int64)
    for _ in 1:nValuations
        model_copy = deepcopy(model)
        addRandomValuations!(model_copy)
        if !checkModelValidity!(model_copy, formula)
            return false
        end
    end
    return true
end

function serialCheckKRModelValidity(formula::Tree, language::String, nodes::Int64, nModels::Int64, infiniteProperties::Bool)
    validCount = 0
    for _ in 1:nModels
        model = generateKRModel(nodes, language, infiniteProperties)
        if checkModelValidity!(model, formula)
            validCount = validCount + 1
        end
    end
    return validCount
end

function serialCheckKRFrameValidity(formula::Tree, language::String, nodes::Int64, nModels::Int64, nFrames::Int64, infiniteProperties::Bool)
    validCount = 0
    for _ in 1:nFrames
        frame = generateKRFrame(nodes, language, infiniteProperties)
        if checkFrameValidity(frame, formula, nModels)
            validCount = validCount + 1
        end
    end
    return validCount
end