function cleanFormula(formula::String)
    cleaned = ""
    for c in formula
        cleaned = cleaned * cleanChar(c)
    end
    return cleaned
end

function cleanChar(c::Char)
    if c in ['^', '∧', '&']
        #takes care of conjunction
        return '∧'
    elseif c in ['v', 'V', '|', '∨']
        #takes care of disjunction
        return '∨'
    elseif c in ['⊃', '-', '→']
        #takes care of implication "->"
        return '→'
    elseif c in ['<', '↔', '≡', '=']
        #takes care of bimplication"<>"
        return '↔'
    elseif c in ['b', '◻']
        # takes care of box
        return '◻'
    elseif c in ['d','◇']
        # takes care of diamond
        return '◇'
    elseif c in ['~','¬']
        # takes care of negation
        return '¬'
    elseif c in ['F', '⊥']
        #takes care of contradiction
        return '⊥'
    elseif c in ['T', '⊤']
        #takes care of truth
        return '⊤'
    elseif c in ['(',')']
        # leaves brackets as they were
        return c
    elseif !isletter(c) || c in ['>']
        #removes all characters which cannot be atoms nor they complete "->" or "<>"
        return ""
    else
        # everything else is treated as propositional atom
        return lowercase(c)
    end    
end