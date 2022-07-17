# LogicToolkit

Welcome to **LogicToolkit** package - logician's best friend!

This package was created based on Bachelor Project by Jakub Łucki and supervised by prof. dr. Rineke Verbrugge. Therefore, all important design choices can be found in the thesis itself under the following link: https://to-be-added. Of course you are more than welcome to take a look if the topic of zero-one laws interests you.

The package uses 2 main representations of formulas: Tree and String. You can switch from one to another by using parseFormula() and formula2String().

Then formulas can be simplified using simplify(). 

The tableau solver has function validate() which can take both strings and trees. To use it you just need to provide premise, consequent and contraints. Constraints can be following: "gl" for transitive and converse well-founded logic, "s4" for transitive and reflexive logic, "k4" for transitive logic.

Then one can generate models and frames using dedicated functions. These structures can be either completely random or follow Kleitman and Rothschild's result. Then one can use checkModelValidity() or checkFrameValidity() to check validity in given structure.

Ultimately, one can generate random formulas of arbitrary depth using generateFormula()