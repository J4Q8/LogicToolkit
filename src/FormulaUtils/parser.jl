"""

  <atom>     ::=  'T' | 'F' | <identifier> | '(' <formula> ')'
  <literal>  ::=  <atom> { '~' <atom> | '◻' <atom> | '◇' <atom> }
 
  <formula>  ::=  <implication> ['<>' <implication> ]
  <implication> ::= <disjunction> [ '->' <disjunction> ]
  <disjunction> ::= <conjunction> {'^' <conjunction> }
  <conjunction> ::= <literal> { 'v' <literal> }


"""


function acceptIdentifier!(s::String, i::Vector{Int})
    idx = i[1]
    if idx <= lastindex(s) && isletter(s[idx])
        i[1] = nextind(s, idx)
        return Tree(s[idx])
    else
        return undef
    end
end

function acceptSymbol!(s::String, i::Vector{Int}, symbol::Char)
    idx = i[1]
    if idx <= lastindex(s) && s[idx] == symbol
        i[1] = nextind(s, idx)
        return Tree(s[idx])
    else
        return undef
    end
end

function acceptAtom!(s::String, i::Vector{Int})

    cont = acceptSymbol!(s, i, '⊥')
    if cont != undef
        return cont
    end 

    truth = acceptSymbol!(s, i, '⊤')
    if truth != undef
        return truth
    end 

    id = acceptIdentifier!(s, i)
    if id != undef
        return id
    end

    #not checked
    bracketl = acceptSymbol!(s, i, '(')
    if bracketl != undef
        formula = acceptFormula!(s,i)
        if formula != undef
            bracketr = acceptSymbol!(s, i, ')')
            if bracketr != undef
                return formula
            end
        end
    end

    return undef
end

function acceptLiteral!(s::String, i::Vector{Int})
    atom = acceptAtom!(s, i)
    if atom != undef
        return atom
    end

    neg = acceptSymbol!(s, i, '¬')
    if neg != undef
        atom = acceptLiteral!(s, i)
        if atom != undef
            addrightchild!(neg, atom)
            return neg
        else 
            return undef
        end
    end 

    box = acceptSymbol!(s, i, '◻')
    if box != undef
        atom = acceptLiteral!(s, i)
        if atom != undef
            addrightchild!(box, atom)
            return box
        else 
            return undef
        end
    end 

    diamond = acceptSymbol!(s, i, '◇')
    if diamond != undef
        atom = acceptLiteral!(s, i)
        if atom != undef
            addrightchild!(diamond, atom)
            return diamond
        else 
            return undef
        end
    end 

    return undef
end

function acceptConjunction!(s::String, i::Vector{Int})
    literal1 = acceptLiteral!(s, i)
    if literal1 == undef
        return undef
    end

    conj = acceptSymbol!(s, i, '∧')
    if conj != undef
        literal2 = acceptConjunction!(s, i)
        if literal2 != undef
            addleftchild!(conj, literal1)
            addrightchild!(conj, literal2)
            return conj
        else
            return undef
        end
    end

    return literal1
end


function acceptDisjunction!(s::String, i::Vector{Int})
    conj1 = acceptConjunction!(s, i)
    if conj1 == undef
        return undef
    end

    disj = acceptSymbol!(s, i, '∨')
    if disj != undef
        conj2 = acceptDisjunction!(s, i)
        if conj2 != undef
            addleftchild!(disj, conj1)
            addrightchild!(disj, conj2)
            return disj
        else
            return undef
        end
    end
    return conj1
end

function acceptImplication!(s::String, i::Vector{Int})

    disj1 = acceptDisjunction!(s, i)
    if disj1 != undef
        imp = acceptSymbol!(s,i,'→')
        if imp != undef
            disj2 = acceptDisjunction!(s, i)
            if disj2 != undef
                addleftchild!(imp, disj1)
                addrightchild!(imp, disj2)
                return imp
            end
        else
            return disj1
        end
    end

    return undef
end

function acceptFormula!(s::String, i::Vector{Int})

    imp1 = acceptImplication!(s, i)
    if imp1 != undef
        bi = acceptSymbol!(s,i,'↔')
        if bi != undef
            imp2 = acceptImplication!(s, i)
            if imp2 != undef
                addleftchild!(bi, imp1)
                addrightchild!(bi, imp2)
                return bi
            end
        else
            return imp1
        end        
    end
    return undef
end

function parseFormula(formula::String)
    formula = cleanFormula(formula)
    wrapper = [1]
    formulatree = acceptFormula!(formula, wrapper)
    if formulatree == undef || wrapper[1] <= lastindex(formula)
        error("Not able to parse the formula")
    end
    return formulatree
end