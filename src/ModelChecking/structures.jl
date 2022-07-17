mutable struct Structure
    frame::DiGraph
    worlds::Vector{Dict{Tree, Bool}}
end

function generateRandomFrame(nStates::Int64, language::String = nothing)
    G = bitrand((nStates, nStates))
    if language == "s4"
        applyTransitiveClosure!(G)
        applyReflexivity!(G)
    elseif language == "k4"
        applyTransitiveClosure!(G)
    elseif language == "gl"
        applyTransitiveClosure!(G)
        makeIrreflexive!(G)
        makeConverseWellFounded!(G)
    end

    worlds = vec([Dict{Tree, Bool}() for _ in 1:n])

    G = DiGraph(G)

    return Structure(G, worlds)
end

function generateKRFrame(n::Int64, language::String, infiniteProperties::Bool = true)
    # generates KR frame

    # n is a total number of states layers will have n/4, n/2, n/4 elements
    m = floor(Int, n/4)
    G = falses(n, n)

    r12 = bitrand(m, 2m)
    if infiniteProperties
        # first layer points cannot be endpoints
        while !minimum(maximum.(eachrow(r12))) || !minimum(maximum.(eachcol(r12)))
            r12 = bitrand(m, 2m)
        end
    end

    r23 = bitrand(2m, m)
    if infiniteProperties
        # neither can be those in second layer
        while !minimum(maximum.(eachrow(r23))) || !minimum(maximum.(eachcol(r23)))
            r23 = bitrand(2m, m)
        end
    end

    G[1:m, m+1:3m] .= G[1:m, m+1:3m] .|| r12
    G[m+1:3m, 3m+1:4m] .= G[m+1:3m, 3m+1:4m] .|| r23

    # this is faster for large matrices (e.g. ~10x faster for n = 80) than transitiveclosure!()
    r13 = (r12*r23) .> 0
    G[1:m,3m+1:4m] .= G[1:m,3m+1:4m] .|| r13

    #add reflexivity and random reflexivity
    if language == "s4"
        applyReflexivity!(G)
    elseif language == "k4"
        applyReflexivity!(G, true)
    end

    worlds = vec([Dict{Tree, Bool}() for _ in 1:n])

    G = DiGraph(G)

    return Structure(G, worlds)
end

function generateKRModel(n::Int64, language::String, infiniteProperties::Bool = true)
    # again KR model
    frame = generateKRFrame(n, language, infiniteProperties)
    addRandomValuations!(frame)
    return frame
end

function applyReflexivity!(mat::BitMatrix, sparse::Bool = false)
    #sparse means that every second world is reflexive if you want to have random reflexive relations use addRandomReflexiveRelations!
    n = size(mat)[1]
    if sparse
        r = BitArray([true, false])
        rep = repeat(r,floor(Int, n/2))
        if length(rep) != n
            rep = [rep; true]
        end
        mat[diagind(mat)] = rep #bitrand(n)
    else
        mat[diagind(mat)] .= true
    end
end

function addRandomReflexiveRelations!(mat::BitMatrix)
    n = size(mat)[1]
    mat[diagind(mat)] = bitrand(n)
end

function applyTransitiveClosure!(structure::Structure)
    transitiveclosure!(structure.frame, true)
end

function makeIrreflexive!(mat::BitMatrix)
    mat[diagind(mat)] .= false
end

function makeCWFRec!(mat::BitMatrix, row::Int64, depth::Int64 = 0)
    cols = findall(mat[row])
    depth = depth + 1
    if depth > 3
        mat[row, col] .= false
        depth = 0
    end
    for col in cols
        makeCWFRec!(mat, col, depth)
    end
end

function makeConverseWellFounded!(mat::BitMatrix)
    n = size(mat)[1, 1:end]
    for i in 1:n
        makeCWFRec!(mat, is)
    end
end

function addRandomValuations!(frame::Structure, atoms::Vector{Char} = ['p', 'q'])
    for idx in 1:length(frame.worlds)
        valuation = bitrand(length(atoms))
        for (v, atom) in enumerate(atoms)
            root = Tree(atom)
            frame.worlds[idx][root] = valuation[v]
        end
    end
end

function addValuations!(frame::Structure, valuations::Vector{Vector{Bool}}, atoms::Vector{Char} = ['p', 'q'])
    for idx in 1:length(frame.worlds)
        valuation = valuations[idx]
        @assert length(valuation) == length(atoms)
        for (v, atom) in enumerate(atoms)
            root = Tree(atom)
            frame.worlds[idx][root] = valuation[v]
        end
    end
end

function getAsymptoticKRModel(language::String)

    if language == "k4"
        # asymptitic model has 12 nodes
        G = falses(24, 24)
        G[1:8, 9:16] .= trues(8, 8) #connections between bottom and middle layer
        G[9:16, 17:24] .= trues(8,8) #connections between middle and upper layer
        G[1:8, 17:24] .= trues(8,8) #connections between bottom and upper layer

        applyReflexivity!(G, true)

        worlds = vec([Dict{Tree, Bool}() for _ in 1:24])
        G = DiGraph(G)
        frame = Structure(G, worlds)

        val = [[false, false], [false, false], [false, true], [false, true], [true, false], [true, false], [true, true], [true, true]]
        allVal = repeat(val, 3)
        addValuations!(frame, allVal)
        return frame
    end

    # asymptitic model has 12 nodes
    G = falses(12, 12)
    G[1:4, 5:8] .= trues(4, 4) #connections between bottom and middle layer
    G[5:8, 9:12] .= trues(4,4) #connections between middle and upper layer
    G[1:4, 9:12] .= trues(4,4) #connections between bottom and upper layer

    #add reflexivity and random reflexivity
    if language == "s4"
        applyReflexivity!(G)
    end

    worlds = vec([Dict{Tree, Bool}() for _ in 1:12])
    G = DiGraph(G)
    frame = Structure(G, worlds)

    val = [[false, false], [false, true], [true, false], [true, true]]
    allVal = repeat(val, 3)
    addValuations!(frame, allVal)

    return frame
end