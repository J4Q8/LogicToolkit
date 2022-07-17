using LogicToolkit
using Test

function isValidModel(formula::String, language::String = "gl")
    formula = parseFormula(formula)
    for _ in 1:10
        model = generateKRModel(80, language)
        if !checkModelValidity!(model, formula)
            return false
        end
    end
    return true
end

function isValidFrame(formula::String, language::String = "gl")
    formula = parseFormula(formula)
    for _ in 1:10
        model = generateKRFrame(80, language)
        if !checkFrameValidity(model, formula, 10)
            return false
        end
    end
    return true
end

function testE(f1::String, f2::String)
    f1 = parseFormula(f1)
    f2 = parseFormula(f2)
    return isEquivalent(f1, f2)
end

function testS(f1::String, f2::String)
    f1 = parseFormula(f1)
    f2 = parseFormula(f2)
    f1 = simplify(f1)
    return isEquivalent(f1, f2)
end

@testset "LogicToolkit.jl" begin
    @testset "ModelCheckerTest" begin

        @testset "Propositional tautologies" begin
            @test isValidModel("( p ↔ q ) ↔ ( ¬ p ↔ ¬ q )") == true
            @test isValidFrame("( p ↔ q ) ↔ ( ¬ p ↔ ¬ q )") == true
            @test isValidModel("( ( p → q ) ∧ ( p → q ) ) → ( p → ( q ∧ q ) )") == true
            @test isValidFrame("( ( p → q ) ∧ ( p → q ) ) → ( p → ( q ∧ q ) )") == true
            @test isValidModel("( p ↔ q ) ↔ ( ¬ p ↔ ¬ q )") == true
            @test isValidFrame("( p ↔ q ) ↔ ( ¬ p ↔ ¬ q )") == true
            @test isValidModel("(p ^ q) -> (p V q)") == true
            @test isValidFrame("(p ^ q) -> (p V q)") == true
        end
    
        @testset "Propositional contradictions" begin
            @test isValidModel("¬(( p ↔ q ) ↔ ( ¬ p ↔ ¬ q ))") == false
            @test isValidFrame("¬(( p ↔ q ) ↔ ( ¬ p ↔ ¬ q ))") == false
            @test isValidModel("¬(( ( p → q ) ∧ ( p → q ) ) → ( p → ( q ∧ q ) ))") == false
            @test isValidFrame("¬(( ( p → q ) ∧ ( p → q ) ) → ( p → ( q ∧ q ) ))") == false
            @test isValidModel("¬(( p ↔ q ) ↔ ( ¬ p ↔ ¬ q ))") == false
            @test isValidFrame("¬(( p ↔ q ) ↔ ( ¬ p ↔ ¬ q ))") == false
            @test isValidModel("¬((p ^ q) -> (p V q))") == false
            @test isValidFrame("¬((p ^ q) -> (p V q))") == false
        end
    
        @testset "Modal tautologies" begin
            @test isValidModel("◇ ( p ∧ q ) → ( ◇ p ∧ ◇ q )") == true
            @test isValidFrame("◇ ( p ∧ q ) → ( ◇ p ∧ ◇ q )") == true
            @test isValidModel("◻ p → p", "s4") == true
            @test isValidFrame("◻ p → p", "s4") == true
            @test isValidModel("◻ p → ◻ ◻ p", "s4") == true
            @test isValidFrame("◻ p → ◻ ◻ p", "s4") == true
            @test isValidModel("◻ p → ◻ ◻ p", "k4") == true
            @test isValidFrame("◻ p → ◻ ◻ p", "k4") == true
            @test isValidModel("( ◻ p ∨ ◻ q ) ↔ ◻ ( ◻ p ∨ ◻ q )", "s4") == true
            @test isValidFrame("( ◻ p ∨ ◻ q ) ↔ ◻ ( ◻ p ∨ ◻ q )", "s4") == true
            @test isValidModel("◻ ( ◻ ( p ↔ q ) → q ) → ( ◻ ( p ↔ q ) → ◻ q )", "s4") == true
            @test isValidFrame("◻ ( ◻ ( p ↔ q ) → q ) → ( ◻ ( p ↔ q ) → ◻ q )", "s4") == true
            @test isValidModel("◻ p → ◻ ◻ p") == true
            @test isValidFrame("◻ p → ◻ ◻ p") == true
            @test isValidModel("◻ ( ◻ p → p ) → ◻p") == true
            @test isValidFrame("◻ ( ◻ p → p ) → ◻p") == true
            @test isValidModel("◇ p → ¬ ⊥") == true
            @test isValidFrame("◇ p → ¬ ⊥") == true
            @test isValidModel("◻ ( ◇ ⊥ → ( p ∧ p ) )") == true
            @test isValidFrame("◻ ( ◇ ⊥ → ( p ∧ p ) )") == true
            @test isValidModel("◻ ( ◻ p → p ) → ◻ p") == true
            @test isValidFrame("◻ ( ◻ p → p ) → ◻ p") == true
            @test isValidModel("( ( ( ( ( ◻ ( ◻ p ∨ ◻ ◇ ¬ p ) ∨ ◇ ◻ ⊥ ) ∨ ◇ ( ◻ p ∧ ◇ ◇ ¬ p ) ) ∨ ◇ ( ◻ ◇ p ∧ ◇ ◇ ◻ ¬ p ) ) ∨ ◇ ( ◻ p ∧ ◻ ¬ p ) ) ∨ ◇ ( ◻ ( ◻ ¬ p ∨ p ) ∧ ◇ ◇ ( ◇ p ∧ ¬ p ) ) ) ∨ ◇ ( ◻ ( ◇ ¬ p ∨ p ) ∧ ◇ ◇ ( ◻ p ∧ ¬ p ) )") == true
            @test isValidFrame("( ( ( ( ( ◻ ( ◻ p ∨ ◻ ◇ ¬ p ) ∨ ◇ ◻ ⊥ ) ∨ ◇ ( ◻ p ∧ ◇ ◇ ¬ p ) ) ∨ ◇ ( ◻ ◇ p ∧ ◇ ◇ ◻ ¬ p ) ) ∨ ◇ ( ◻ p ∧ ◻ ¬ p ) ) ∨ ◇ ( ◻ ( ◻ ¬ p ∨ p ) ∧ ◇ ◇ ( ◇ p ∧ ¬ p ) ) ) ∨ ◇ ( ◻ ( ◇ ¬ p ∨ p ) ∧ ◇ ◇ ( ◻ p ∧ ¬ p ) )") == true
        end
    
        @testset "Modal contradictions" begin
            @test isValidModel("¬(◇ ( p ∧ q ) → ( ◇ p ∧ ◇ q ))") == false
            @test isValidFrame("¬(◇ ( p ∧ q ) → ( ◇ p ∧ ◇ q ))") == false
            @test isValidModel("¬(◻ p → p)") == false
            @test isValidFrame("¬(◻ p → p)") == false
            @test isValidModel("¬(◻ p → ◻ ◻ p)", "s4") == false
            @test isValidFrame("¬(◻ p → ◻ ◻ p)", "s4") == false
            @test isValidModel("¬(◻ p → ◻ ◻ p)", "k4") == false
            @test isValidFrame("¬(◻ p → ◻ ◻ p)", "k4") == false
            @test isValidModel("¬(( ◻ p ∨ ◻ q ) ↔ ◻ ( ◻ p ∨ ◻ q ))", "s4") == false
            @test isValidFrame("¬(( ◻ p ∨ ◻ q ) ↔ ◻ ( ◻ p ∨ ◻ q ))", "s4") == false
            @test isValidModel("¬(◻ ( ◻ ( p ↔ q ) → p ) → ( ◻ ( p ↔ q ) → ◻ p ))", "s4") == false
            @test isValidFrame("¬(◻ ( ◻ ( p ↔ q ) → p ) → ( ◻ ( p ↔ q ) → ◻ p ))", "s4") == false
            @test isValidModel("¬(◻ p → ◻ ◻ p)") == false
            @test isValidFrame("¬(◻ p → ◻ ◻ p)") == false
            @test isValidModel("¬(◻ ( ◻ p → p ) → ◻p)") == false
            @test isValidFrame("¬(◻ ( ◻ p → p ) → ◻p)") == false
            @test isValidModel("¬(◇ p → ¬ ⊥)") == false
            @test isValidFrame("¬(◇ p → ¬ ⊥)") == false
            @test isValidModel("¬(◻ ( ◇ ⊥ → ( p ∧ p ) ))") == false
            @test isValidFrame("¬(◻ ( ◇ ⊥ → ( p ∧ p ) ))") == false
            @test isValidModel("¬(◻ ( ◻ p → p ) → ◻ p)") == false
            @test isValidFrame("¬(◻ ( ◻ p → p ) → ◻ p)") == false
            @test isValidModel("¬(( ( ( ( ( ◻ ( ◻ p ∨ ◻ ◇ ¬ p ) ∨ ◇ ◻ ⊥ ) ∨ ◇ ( ◻ p ∧ ◇ ◇ ¬ p ) ) ∨ ◇ ( ◻ ◇ p ∧ ◇ ◇ ◻ ¬ p ) ) ∨ ◇ ( ◻ p ∧ ◻ ¬ p ) ) ∨ ◇ ( ◻ ( ◻ ¬ p ∨ p ) ∧ ◇ ◇ ( ◇ p ∧ ¬ p ) ) ) ∨ ◇ ( ◻ ( ◇ ¬ p ∨ p ) ∧ ◇ ◇ ( ◻ p ∧ ¬ p ) ))") == false
            @test isValidFrame("¬(( ( ( ( ( ◻ ( ◻ p ∨ ◻ ◇ ¬ p ) ∨ ◇ ◻ ⊥ ) ∨ ◇ ( ◻ p ∧ ◇ ◇ ¬ p ) ) ∨ ◇ ( ◻ ◇ p ∧ ◇ ◇ ◻ ¬ p ) ) ∨ ◇ ( ◻ p ∧ ◻ ¬ p ) ) ∨ ◇ ( ◻ ( ◻ ¬ p ∨ p ) ∧ ◇ ◇ ( ◇ p ∧ ¬ p ) ) ) ∨ ◇ ( ◻ ( ◇ ¬ p ∨ p ) ∧ ◇ ◇ ( ◻ p ∧ ¬ p ) ))") == false
        end

        @testset "Randomly generated modal tautologies" begin
            # line 26 in tripleTC.txt
            @test isValidModel(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )") == true
            @test isValidFrame(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )") == true
            @test isValidModel(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )", "k4") == true
            @test isValidFrame(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )", "k4") == true
            @test isValidModel(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )", "s4") == true
            @test isValidFrame(" ¬ ( ( ◇ ⊤ ↔ q ) ∨ ◇ p ) ∨ ( ( ( p ∨ q ) ↔ ¬ p ) → q )", "s4") == true
            # # line 39 in tripleTC.txt
            @test isValidModel("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )") == true
            @test isValidFrame("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )") == true
            @test isValidModel("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )", "k4") == true
            @test isValidFrame("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )", "k4") == true
            @test isValidModel("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )", "s4") == true
            @test isValidFrame("◻ ⊥ → ◻ ( ( ◻ ◻ q ∨ p ) ∧ q )", "s4") == true
            # # line 43 in tripleTC.txt
            @test isValidModel("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )") == true
            @test isValidFrame("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )") == true
            @test isValidModel("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )", "k4") == true
            @test isValidFrame("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )", "k4") == true
            @test isValidModel("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )", "s4") == true
            @test isValidFrame("( ◇ p → ◻ q ) ∨ ( p → ( ( ¬ p ∨ ◻ ⊥ ) → ( ¬ ( q ∧ ◻ ⊥ ) ∨ ( p ∧ ( ◻ q → q ) ) ) ) )", "s4") == true
            # line 72 in tripleTC.txt
            @test isValidModel("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )") == true
            @test isValidFrame("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )") == true
            @test isValidModel("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )", "k4") == true
            @test isValidFrame("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )", "k4") == true
            @test isValidModel("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )", "s4") == true
            @test isValidFrame("p → ( ◻ ( ( ¬ q ∧ ¬ ( p ∧ q ) ) ↔ ( ◻ ( p ∧ q ) → p ) ) ∨ ( ( ◇ ¬ q → ( ¬ ( ( p ↔ q ) ∨ ◻ p ) ∧ ( q → ◻ ◇ ◇ p ) ) ) ∨ ( ( ◻ ◻ ⊥ → ( ◻ ⊥ → ( ( ¬ p → ( ◇ ¬ q ∧ ◻ ⊥ ) ) ∨ ( ( ( q → ◇ p ) ∧ ◇ q ) ∨ p ) ) ) ) ∨ ( ( ( ◻ ⊥ ↔ p ) ∧ ◇ q ) ∨ ( p ∧ ( ◻ ⊥ ↔ ( ( q → p ) ∨ ( q ∨ p ) ) ) ) ) ) ) )", "s4") == true
            # line 94 in tripleTC.txt
            @test isValidModel("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )") == true
            @test isValidFrame("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )") == true
            @test isValidModel("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )", "k4") == true
            @test isValidFrame("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )", "k4") == true
            @test isValidModel("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )", "s4") == true
            @test isValidFrame("◇ p → ( ¬ ( p → ( ◇ ⊤ → ( ◇ ( ◇ p ↔ ( ◻ ⊥ ↔ ( ¬ p → ¬ q ) ) ) ↔ p ) ) ) → p )", "s4") == true
        end

        @testset "Randomly generated modal contradictions" begin
            # line 55 in tripleTC.txt
            @test isValidModel("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )") == false
            @test isValidFrame("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )") == false
            @test isValidModel("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )", "k4") == false
            @test isValidFrame("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )", "k4") == false
            @test isValidModel("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )", "s4") == false
            @test isValidFrame("q ∧ ◇ ( ◻ q ∧ ◇ ◇ ¬ ( p ∨ q ) )", "s4") == false
            # line 91 in tripleTC.txt
            @test isValidModel("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )") == false
            @test isValidFrame("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )") == false
            @test isValidModel("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )", "k4") == false
            @test isValidFrame("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )", "k4") == false
            @test isValidModel("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )", "s4") == false
            @test isValidFrame("q ∧ ( ¬ ( q ∨ ◇ ¬ p ) ∧ ◻ ◻ ¬ ( ( ( ◇ ( q → ◻ q ) ∧ ( q → ◇ ◇ q ) ) → p ) ∧ ◻ p ) )", "s4") == false
            # line 64 in tripleTC.txt
            @test isValidModel("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )") == false
            @test isValidFrame("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )") == false
            @test isValidModel("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )", "k4") == false
            @test isValidFrame("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )", "k4") == false
            @test isValidModel("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )", "s4") == false
            @test isValidFrame("¬ ( ( q → ( q ∨ ( ◇ ◻ ¬ ( q ∨ p ) → p ) ) ) ∨ ◻ q )", "s4") == false
            # line 49 in tripleTC.txt
            @test isValidModel("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )") == false
            @test isValidFrame("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )") == false
            @test isValidModel("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )", "k4") == false
            @test isValidFrame("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )", "k4") == false
            @test isValidModel("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )", "s4") == false
            @test isValidFrame("◇ ¬ ( ( q ∧ ( ◻ q ∧ ◻ ( q → ¬ q ) ) ) → ( ◇ p → ◇ ¬ p ) )", "s4") == false
            # line 1 in tripleTC.txt
            @test isValidModel("◇ ⊤ ↔ ◻ ⊥") == false
            @test isValidFrame("◇ ⊤ ↔ ◻ ⊥") == false
            @test isValidModel("◇ ⊤ ↔ ◻ ⊥", "k4") == false
            @test isValidFrame("◇ ⊤ ↔ ◻ ⊥", "k4") == false
            @test isValidModel("◇ ⊤ ↔ ◻ ⊥", "s4") == false
            @test isValidFrame("◇ ⊤ ↔ ◻ ⊥", "s4") == false
            
        end
    
    end

    @testset "isEquivalent" begin

        @testset "multiple conjuncts" begin
            @test testE("p ∧ ( q ∧ r )", "(p ∧ q) ∧ r")
            @test testE("p ∧ ( q ∧ r )", "(p ∧ r) ∧ q")
            @test testE("(p^r)^(q^r)", "((p^p)^q)^r")
            @test testE("p^r", "r^p")
            @test testE("T", "~F")
            @test testE("~T", "~~F")
            @test testE("T^F", "F^T")
            @test testE("p^(q^(r^F))", "(~T^q)^(p^r)")
        end
    
        @testset "multiple disjuncts" begin
            @test testE("p V ( q V r )", "(p V q) V r")
            @test testE("p V ( q V r )", "(p V r) V q")
            @test testE("(pVr)V(qVr)", "((pVp)Vq)Vr")
            @test testE("pVr", "rVp")
            @test testE("TVF", "FVT")
            @test testE("~T", "F")
            @test testE("~~T", "~F")
            @test testE("pV(qV(rVF))", "(~TVq)V(pVr)")
        end 
    
        @testset "multiple bimplications" begin
            @test testE("p = ( q = r )", "(p = q) = r")
            @test testE("p = ( q = r )", "(p = r) = q")
            @test testE("(p=r)=(q=r)", "((p=p)=q)=r")
            @test testE("p=r", "r=p")
            @test testE("T=F", "F=T")
            @test testE("~T", "F")
            @test testE("~~T", "~F")
            @test testE("p=(q=(r=F))", "(~T=q)=(p=r)")
        end
    
    end
    
    @testset "Simplifier tests" begin
    
        @testset "multiple conjuncts" begin
            @test testS("(T^T)^F", "F")
            @test testS("(T^T)^(T^T)", "T")
            @test testS("(T^T)^(T^F)", "F")
            @test testS("(T^p)^(T^T)", "p")
            @test testS("(T^p)^(F^T)", "F")
            @test testS("(T^p)^(T^~p)", "F")
            @test testS("(T^p)^(r^p)", "p^r")
            @test testS("(T^p)^(r^(p^(F^T)))", "F")
            @test testS("(T^p)^(r^(p^(q^T)))", "p^(r^q)")
            @test testS("(~q^p)^(r^(p^(q^T)))", "F")
        end
    
        @testset "multiple disjuncts" begin
            @test testS("(TVT)VF", "T")
            @test testS("(TVT)V(TVT)", "T")
            @test testS("(FVT)V(TVF)", "T")
            @test testS("(TVp)V(TVT)", "T")
            @test testS("(FVp)V(FVF)", "p")
            @test testS("(TVp)V(FVT)", "T")
            @test testS("(TVp)V(TV~p)", "T")
            @test testS("(FVF)V(FV~T)", "F")
            @test testS("(FVp)V(rVp)", "pVr")
            @test testS("(TVp)V(rV(pV(FVT)))", "T")
            @test testS("(FVp)V(rV(pV(qVF)))", "pV(rVq)")
            @test testS("(~qVp)V(rV(pV(qVT)))", "T")
        end 
    
        @testset "multiple bimplications" begin
            @test testS("(T↔T)↔F", "F")
            @test testS("(T↔T)↔(T↔T)", "T")
            @test testS("(F↔T)↔(T↔F)", "T")
            @test testS("(T↔p)↔(T↔T)", "p")
            @test testS("(F↔p)↔(F↔F)", "~p")
            @test testS("(T↔p)↔(F↔T)", "~p")
            @test testS("(T↔p)↔(T↔~p)", "F")
            @test testS("(F↔F)↔(F↔~T)", "T")
            @test testS("(F↔p)↔(r↔p)", "~r")
            @test testS("(T↔p)↔(r↔(p↔(F↔T)))", "~r")
            @test testS("(F↔p)↔(r↔(p↔(q↔F)))", "q↔r")
            @test testS("(~q↔p)↔(r↔(p↔(q↔T)))", "~r")
        end 
    
        @testset "complex simplifications" begin
            @test testS("(~q^p)^(r^(p^(q-T)))", "((p^~q)^r)")
            @test testS("◻ ( ◻ ⊤ ∧ ◻ ( ◻ ( q → p ) ↔ ( ◻ ⊥ ∧ ( ⊥ ∧ ⊤ ) ) ) )", "◻ ( ◻ ( ◇~ ( q → p )) )")
            @test testS("(p->q)^~(p->q)" ,"F")
            @test testS("((p->q)^~(p->q))V((p=p)->q)" ,"q")
            @test testS("(◻ ⊤ ∧ (( ◇ F) ^p))->(p^~p)" ,"T")
            @test testS("(~◻ F ∧ ~◇(( ◇ F) ^p))->(p^~p)" ,"◻ F ")
            @test testS("((((~~~~~pVp)=T)->F)->F)^(r^p)", "r^p")
        end 
        
    
    end

    @testset verbose = true "Tableau tests" begin

        @testset "propositional formulas" begin
            @test validate("( p → q ) ∧ p", "q") == true
            @test validate("( p → q ) ∧ ( q → r )", "( p → r )") == true
            @test validate("", "( ( p → q ) ∧ ( p → r ) ) → ( p → ( q ∧ r ) )") == true
            @test validate("( p → q ) ∨ ( r → q )", "( p ∨ r ) → q") == false
            @test validate("", "( p ↔ q ) ↔ ( ¬ p ↔ ¬ q )") == true
        end

        @testset "modal formulas" begin
            @test validate("◻ ( p → q ) ∧ ◻ ( q → r )", "◻ ( p → r )") == true
            @test validate("", "◇ ( p ∧ q ) → ( ◇ p ∧ ◇ q )") == true
            @test validate("◇ ◻ ◇p", "◇p") == false
            @test validate(" ◻ ( p ∧ q )", "◻ p ∧ ◻ q") == true
            @test validate("◇p", "◇ ◻ ◇p") == false
            @test validate("", "◻ p → p") == false
        end 

        @testset "modal formulas with constraints" begin
            @test validate("", "◻ p → p", "r") == true
            @test validate("", "◻ p → ◻ ◻ p", "r") == false
            @test validate("", "◻ p → ◻ ◻ p", "rt") == true
            @test validate("", "p → ◻ ◇ p", "s") == true
            @test validate("", "◻ p → ◻ ◻ p", "t") == true
            @test validate("", "◇ p → ◻ ◇ p", "st") == true
            @test validate("", "◻ p → ◻ ◻ p", "rs") == false
            @test validate("", "◻ ◻ p → ◻ p", "t") == false
            @test validate("", "( ◻ ( p → q ) ∧ ◇ ( p ∧ r ) ) → ◇ ( q ∧ r )", "r") == true
            @test validate("", "( ◻ p ∧ ◻ q ) → ( p ↔ q )", "r") == true
            @test validate("", "◇ ( p → q ) ↔ ( ◻ p → ◇ q )", "r") == true
            @test validate("", "( ◇ ¬ p ∨ ◇ ¬ q ) ∨ ◇ ( p ∨ q )", "r") == true
            @test validate("", "◇ ( p → ( q ∧ r ) ) → ( ( ◻ p → ◇ q ) ∧ ( ◻ p → ◇ r ) )", "r") == true
            @test validate("", "( ◻ p ∨ ◻ q ) ↔ ◻ ( ◻ p ∨ ◻ q )", "rt") == true
            @test validate("", "◻ ( ◻ ( p ↔ q ) → r ) → ( ◻ ( p ↔ q ) → ◻ r )", "rt") == true
            @test validate("", "◻ p → ◻ ◻ p", "gl") == true
            @test validate("", "◻ ( ◻ p → p ) → ◻p", "gl") == true
            @test validate("", "¬ p ∨p", "gl") == true
            @test validate("", "p →p", "gl") == true
            @test validate("", "¬ ⊥", "gl") == true
            @test validate("", "( p ∧ q ) ∨ ( ¬ p ∨ ¬ q )", "gl") == true
            @test validate("", "◇ p → ¬ ⊥", "gl") == true
            @test validate("", "◻ ( ◇ ⊥ → ( p ∧ p ) )", "gl") == true
            @test validate("", "( p ∨ p ) ↔ ( ⊥ ∨ p )", "gl") == true
            @test validate("", "p ∧ ¬p", "gl") == false
            @test validate("", "p ∨p", "gl") == false
            @test validate("", "◻ ◻p", "gl") == false
            @test validate("", "( p ∨ ¬ p ) ∧ ( ( ¬ ⊥ ∧ ¬ ⊥ ) ∧ p )", "gl") == false
            @test validate("", "( ⊥ ∧ ⊥ ) ∨ ( ( p ∨ p ) ↔ ( q ∨ q ) )", "gl") == false
            @test validate("", "◇ p → ¬ q", "gl") == false
            @test validate("", "◻ ◻ ◇ ( p ↔ p ) ∧ ◻ ◻ ◇ ◻ ( p ∧ ¬ p )", "gl") == false
            @test validate("", "◻ ( ◻ p → p ) → ◻ p", "gl") == true
            @test validate("", "( ( ( ( ( ◻ ( ◻ a ∨ ◻ ◇ ¬ a ) ∨ ◇ ◻ ⊥ ) ∨ ◇ ( ◻ a ∧ ◇ ◇ ¬ a ) ) ∨ ◇ ( ◻ ◇ a ∧ ◇ ◇ ◻ ¬ a ) ) ∨ ◇ ( ◻ a ∧ ◻ ¬ a ) ) ∨ ◇ ( ◻ ( ◻ ¬ a ∨ a ) ∧ ◇ ◇ ( ◇ a ∧ ¬ a ) ) ) ∨ ◇ ( ◻ ( ◇ ¬ a ∨ a ) ∧ ◇ ◇ ( ◻ a ∧ ¬ a ) )", "gl") == true
        end 

        @testset "modal formulas with infinite branches" begin
            @test validate("◻ ( ◻ ⊤ ∧ ◻ ( ◻ ( q → p ) ↔ ( ◻ ⊥ ∧ ( ⊥ ∧ ⊤ ) ) ) )", "", "s4") == false
            @test validate("◻ ( ◻ p ↔ ◻ ⊥ )", "", "s4") == false
            @test validate("◻ ( p ↔ ◻ ⊥ )", "", "s4") == false
            @test validate("", "¬ ( ◇ p ∧ ◻ ◇ p )", "t") == false
            @test validate("( ( ◻ ◻ ¬ p → ( ( ¬ p ∧ ( p ↔ q ) ) ∧ p ) ) ∧ ◇ ¬ ◇ ( p ∧ ⊤ ) ) ↔ ◻ ( ◻ ◇ ( q ↔ ⊥ ) ∧ ◻ ( p ↔ ( ⊤ ∧ p ) ) )", "", "s4") == false
            @test validate("◇ ( ◇ ( ◇ ( p ∧ q ) ↔ ( ( ( p ∧ ⊥ ) → ( ⊥ → p ) ) ↔ q ) ) ↔ ¬ ( ( ⊤ ↔ ◻ p ) ∧ ¬ ◻ p ) ) ∧ ◻ ◻ ( ◇ ⊤ ∧ ¬ ( ¬ ( p ∧ ⊥ ) ∧ ( ( ⊤ ∧ p ) ∧ ⊥ ) ) )", "", "s4") == false
            @test validate("◇ ◻ ¬ ◻ p ↔ ( ⊥ ↔ ◻ ( ◻ ( ◇ ◻ p ↔ p ) ∧ ◻ ( ( ◇ q ∧ ( ⊤ ∧ ⊥ ) ) ↔ q ) ) )", "", "s4") == false
            
        end

    end
end
