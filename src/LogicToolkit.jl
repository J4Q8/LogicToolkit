module LogicToolkit

using StatsBase
using LinearAlgebra
using Random: bitrand
using LightGraphs
using Statistics

include("FormulaUtils/trees.jl")
include("FormulaUtils/cleaner.jl")
include("FormulaUtils/parser.jl")
include("FormulaUtils/simplifier.jl")
include("FormulaGeneration/formulaGenerator.jl")
include("ModelChecking/structures.jl")
include("ModelChecking/modelChecker.jl")
include("Tableau-solver/tableaux.jl")
include("Tableau-solver/modalRules.jl")
include("Tableau-solver/propositionalRules.jl")
include("Tableau-solver/solver.jl")
include("Tableau-solver/interface.jl")

export generateFormula
export parseFormula
export simplify
export Tree, addleftchild!, addrightchild!, replaceleftchild!, replacerightchild!, height, isequal, isOpposite, isEquivalent, isOppositeEqui, printFormula, formula2String
export Structure, generateRandomFrame, generateKRFrame, generateKRModel, addRandomValuations!, neighbors, getAsymptoticKRModel
export checkModelValidity!, checkFrameValidity, serialCheckKRModelValidity, serialCheckKRFrameValidity
export Tableau, addFormula!, printBranch
export solve!
export validate, isTautology, isContradiction, addPremise!, addConsequent!

end
