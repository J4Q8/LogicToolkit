function parseConstraints(constraint::String)
    restrictions = Char[]
    if constraint == "gl"
        push!(restrictions, 'c') # the rules for converse well founded already have transitivity
    elseif constraint == "s4"
        push!(restrictions, 't')
        push!(restrictions, 'r')
    elseif constraint == "k4"
        push!(restrictions, 't')
    else
        possible = ['t', 'r', 's', 'c']
        for l in constraint
            if l in possible
                push!(restrictions, l)
            end
        end
    end
    return restrictions
end

function addPremise!(tableau::Tableau, formula::Tree)
    addFormula!(tableau, formula, 0)
end

function parseAndAddPremise!(tableau::Tableau, formula::String, mode::Int64 = 1)
    if !isempty(formula)
        try
            formula = parseFormula(formula)
            addPremise!(tableau, formula)
            if mode == 1
                printFormula(formula)
                print("\n")
            end
        catch
            error(formula, " :cannot be parsed")
        end
    end
end

function addConsequent!(tableau::Tableau, formula::Tree)
    negformula = Tree('¬')
    addrightchild!(negformula, formula)
    addFormula!(tableau, negformula, 0)
end

function parseAndAddConsequent!(tableau::Tableau, formula::String, mode::Int64 = 1)
    if !isempty(formula)
        try
            formula = parseFormula(formula)
            addConsequent!(tableau, formula)
            if mode == 1
                printFormula(formula)
                print("\n")
            end
        catch
            error(formula, " :cannot be parsed")
        end
    end
end

function validate(premise::String = "", consequent::String = "", constraints::String = "")
    constraintsCharVec = parseConstraints(constraints)
    tableau = Tableau()
    parseAndAddPremise!(tableau, premise, 2)
    parseAndAddConsequent!(tableau, consequent, 2)
    
    return solve!(tableau, constraintsCharVec, 2)
end

function validate(;premise::Tree = Tree('~'), consequent::Tree = Tree('~'), constraints::String = "")
    constraintsCharVec = parseConstraints(constraints)
    tableau = Tableau()
    if premise.connective != '~'
        addPremise!(tableau, premise)
    end
    if consequent.connective != '~'
        addConsequent!(tableau, consequent)
    end
    return solve!(tableau, constraintsCharVec, 2)
end

function isTautology(formula::Tree, constrains::String)
    return validate(consequent=formula, constraints=constrains)
end

function isContradiction(formula::Tree, constrains::String)
    return validate(premise=formula, constraints = constrains)
end