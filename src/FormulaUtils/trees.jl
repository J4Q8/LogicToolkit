"""
Inspiration from https://github.com/JuliaCollections/AbstractTrees.jl/blob/master/examples/binarytree_core.jl
        and from https://github.com/andrewcooke/AutoHashEquals.jl
"""

mutable struct Tree
    connective::Char
    left::Tree
    right::Tree

    # Root constructor
    Tree(symbol) = new(symbol)
    Tree(symbol, l, r) = new(symbol, l, r)
end

Base.hash(a::Tree, h::UInt) = hash(myHash(a), hash(:Tree, h)) #hash(a.b, hash(a.a, hash(:Foo, h)))
#Base.(:(==))(a::Tree, b::Tree) = isequal(a, b)

function addleftchild!(parent::Tree, symbol::Tree)
    !isdefined(parent, :left) || error("left child is already assigned")
    parent.left = deepcopy(symbol)
end

function addleftchild!(parent::Tree, symbol::Char)
    !isdefined(parent, :left) || error("left child is already assigned")
    parent.left = Tree(symbol)
end

function addrightchild!(parent::Tree, symbol::Tree)
    !isdefined(parent, :right) || error("right child is already assigned")
    parent.right = deepcopy(symbol)
end

function addrightchild!(parent::Tree, symbol::Char)
    !isdefined(parent, :right) || error("right child is already assigned")
    parent.right = Tree(symbol)
end

function replaceleftchild!(parent::Tree, symbol::Tree)
    parent.left = deepcopy(symbol)
end

function replacerightchild!(parent::Tree, symbol)
    parent.right = deepcopy(symbol)
end

function printFormula(formulatree::Tree)
    if formulatree == undef
        print("Ups...")
        return
    end

    if isdefined(formulatree, :left)
        if !isdefined(formulatree.left, :left) || !isdefined(formulatree.left, :right)
            printFormula(formulatree.left)
        else
            print(" (")
            printFormula(formulatree.left)
            print(" )")
        end
    end
    
    print(" ", formulatree.connective)

    if isdefined(formulatree, :right)
        if !isdefined(formulatree.right, :left) || !isdefined(formulatree.right, :right)
            printFormula(formulatree.right)
        else
            print(" (")
            printFormula(formulatree.right)
            print(" )")
        end
    end
end

function formula2String(formulatree::Tree)
    if formulatree == undef
        error("you shouldn't end up here")
        return
    end

    left = ""
    if isdefined(formulatree, :left)
        if !isdefined(formulatree.left, :left) || !isdefined(formulatree.left, :right)
            left = formula2String(formulatree.left)
        else
            left = " (" * formula2String(formulatree.left) * " )"
        end
    end

    middle = " "*formulatree.connective

    right = ""
    if isdefined(formulatree, :right)
        if !isdefined(formulatree.right, :left) || !isdefined(formulatree.right, :right)
            right = formula2String(formulatree.right)
        else
            right = " (" * formula2String(formulatree.right) * " )"
        end
    end
    return left*middle*right
end

function height(tree::Tree)
    # we count the root node.
    lh = 0
    rh = 0

    if isdefined(tree, :left)
        lh = height(tree.left)
    end
    if isdefined(tree, :right)
        rh = height(tree.right)
    end
    return max(lh, rh) + 1
end

function myHash(t::Tree)
    lh = hash(0)
    rh = hash(0)

    if isdefined(t, :left)
        lh = myHash(t.left)
    end

    if isdefined(t, :rigth)
        rh = myHash(t.right)
    end

    return hash(t.connective, hash(lh, rh))
end

function Base.:(==)(t1::Tree, t2::Tree)
    return isequal(t1,t2)
end

function Base.:isequal(t1::Tree, t2::Tree)
    # this function checks if 2 trees are exactly the same

    # I am pretty sure this can be simplified but I have no idea how, since you cannot access undefined 
    #checks if two trees are equivalent
    
    #the base cases check that if a child is undefined then it has to be undefined in t2 as well otherwise it is false
    if !isdefined(t1, :left) && isdefined(t2, :left)
        return false
    end

    if !isdefined(t1, :right) && isdefined(t2, :right)
        return false
    end

    if !isdefined(t2, :left) && isdefined(t1, :left)
        return false
    end

    if !isdefined(t2, :right) && isdefined(t1, :right)
        return false
    end


    # if !isdefined(t1, :left) && !isdefined(t2, :left) && !isdefined(t1, :right) && !isdefined(t2, :right)
    #     return true
    # end

    if t1.connective == t2.connective
        if !isdefined(t1, :left)
            if !isdefined(t1, :right)
                return true
            else
                return isequal(t1.right, t2.right)
            end
        elseif !isdefined(t1, :right)
            return isequal(t1.left, t2.lfet)
        else
            return isequal(t1.left, t2.left) && isequal(t1.right, t2.right)
        end
    else
        return false
    end
end

function isOpposite(t1::Tree, t2::Tree)
    # exactly opposite
    if t1.connective == '¬'
        if t2.connective == '¬'
            #make sure that multiple repeating negations are removed
            return isOpposite(t1.right, t2.right)
        else
            return isequal(t1.right, t2)
        end
    elseif t2.connective == '¬'
        return isequal(t1, t2.right)
    else
        return false
    end
end

function getJuncts(formula::Tree, connective::Char)
    # get conjuncts and disjuncts and biconditionals
    if formula.connective == connective
        return [getJuncts(formula.left, connective); getJuncts(formula.right, connective)]
    else
        return [formula]
    end

end

function compareJuncts(j1::Vector{Tree}, j2::Vector{Tree})
    v1 = fill(0, length(j1))
    v2 = fill(0, length(j2))
    for (idx1, junct1) in enumerate(j1)
        for (idx2, junct2) in enumerate(j2)
            t = isEquivalent(junct1, junct2)
            v1[idx1] = t ? 1 : v1[idx1]
            v2[idx2] = t ? 1 : v2[idx2]
            if minimum(v1) == 1 && minimum(v2) == 1
                return true
            end
        end
    end
    if minimum(v1) == 0 || minimum(v2) == 0
        return false
    else
        return true
    end
end

function isEquivalent(t1::Tree, t2::Tree)
    #check if formulas are equivalent e.g. A^B and B^A are    
    if !isdefined(t1, :left) && isdefined(t2, :left)
        return false
    end

    if !isdefined(t1, :right) && isdefined(t2, :right)
        if t2.connective == '¬' && t1.connective == '⊤' && t2.right.connective == '⊥'
            return true
        elseif t2.connective == '¬' && t1.connective == '⊥' && t2.right.connective == '⊤'
            return true
        else
            return false
        end
    end

    if !isdefined(t2, :left) && isdefined(t1, :left)
        return false
    end

    if !isdefined(t2, :right) && isdefined(t1, :right)
        if t1.connective == '¬' && t1.right.connective == '⊥' && t2.connective == '⊤'
            return true
            #hard coded fact that neg F equals to T
        elseif t1.connective == '¬' && t1.right.connective == '⊤' && t2.connective == '⊥'
            return true
        else
            return false
        end
    end

    if t1.connective == t2.connective
        if !isdefined(t1, :left)
            if !isdefined(t1, :right)
                return true
            else
                return isEquivalent(t1.right, t2.right)
            end
        elseif !isdefined(t1, :right)
            # this should never be the case, because either the treenode has two children 
            #   or one child on the right
            return isEquivalent(t1.left, t2.lfet)
        else
            equal = isEquivalent(t1.left, t2.left) && isEquivalent(t1.right, t2.right)
            if !equal && t1.connective in ['∧', '↔', '∨'] # commutative and associative connectives
                j1 = getJuncts(t1, t1.connective)
                j2 = getJuncts(t2, t2.connective)
                symmetrical_associative_commutative = compareJuncts(j1, j2)
                return equal || symmetrical_associative_commutative
            else
                return equal
            end
        end
    else
        return false
    end
end

function isOppositeEqui(t1::Tree, t2::Tree)
    #this function is based on equivalences
    if t1.connective == '¬'
        if t2.connective == '¬'
            return isOppositeEqui(t1.right, t2.right)
        else
            return isEquivalent(t1.right, t2)
        end
    elseif t2.connective == '¬'
        return isEquivalent(t1, t2.right)
        # hardcoded fact that T and F are opposites
    elseif t1.connective in ['⊥','⊤'] && t2.connective in ['⊥','⊤'] && t1.connective != t2.connective
        return true
    else
        return false
    end

end