//
//  ParserFunctions.swift
//  SynthApp
//
//  Created by Pierre Juliot on 08/04/2021.
//

import Foundation

public enum Associativity {
    case Left
    case Right
}

public struct Operator {

    public init(representation: String, priority: Int, associativity: Associativity, imp: (([Float]) -> Float)?, numArgs: Int = 2, isFunction: Bool = false) {
        self.representation = representation
        self.priority = priority
        self.associativity = associativity
        self.imp = imp
        self.numArgs = numArgs
        self.isFunction = isFunction
    }

    let representation: String
    let priority: Int
    let associativity: Associativity
    let imp: (([Float]) -> Float)?
    let numArgs: Int
    let isFunction: Bool
}

/**
    An object that allows you to calculate a math expression string
 */
public class Parser {

    private let operators: [Operator] = [Operator(representation: "(", priority: 0, associativity: Associativity.Left, imp: nil),
                                          Operator(representation: ")", priority: 0, associativity: Associativity.Left, imp: nil),
                                          Operator(representation: ",", priority: 4, associativity: Associativity.Left, imp: nil),

                                          Operator(representation: "^", priority: 0, associativity: Associativity.Right, imp: Functions._pow),
                                          Operator(representation: "*", priority: 2, associativity: Associativity.Left, imp: Functions._mul),
                                          Operator(representation: "/", priority: 2, associativity: Associativity.Left, imp: Functions._div),
                                          Operator(representation: "%", priority: 2, associativity: Associativity.Left, imp: Functions._mod),
                                          Operator(representation: "+", priority: 3, associativity: Associativity.Left, imp: Functions._add),
                                          Operator(representation: "-", priority: 3, associativity: Associativity.Left, imp: Functions._sub),

                                          Operator(representation: "sin", priority: 0, associativity: Associativity.Left, imp: Functions._sin, numArgs: 1, isFunction: true),
                                          Operator(representation: "cos", priority: 0, associativity: Associativity.Left, imp: Functions._cos, numArgs: 1, isFunction: true),
                                          Operator(representation: "tan", priority: 0, associativity: Associativity.Left, imp: Functions._tan, numArgs: 1, isFunction: true),

                                          Operator(representation: "sinh", priority: 0, associativity: Associativity.Left, imp: Functions._sinh, numArgs: 1, isFunction: true),
                                          Operator(representation: "cosh", priority: 0, associativity: Associativity.Left, imp: Functions._cosh, numArgs: 1, isFunction: true),
                                          Operator(representation: "tanh", priority: 0, associativity: Associativity.Left, imp: Functions._tanh, numArgs: 1, isFunction: true),

                                          Operator(representation: "asinh", priority: 0, associativity: Associativity.Left, imp: Functions._asinh, numArgs: 1, isFunction: true),
                                          Operator(representation: "acosh", priority: 0, associativity: Associativity.Left, imp: Functions._acosh, numArgs: 1, isFunction: true),
                                          Operator(representation: "atanh", priority: 0, associativity: Associativity.Left, imp: Functions._atanh, numArgs: 1, isFunction: true),

                                          Operator(representation: "atan", priority: 0, associativity: Associativity.Left, imp: Functions._atan, numArgs: 1, isFunction: true),
                                          Operator(representation: "asin", priority: 0, associativity: Associativity.Left, imp: Functions._asin, numArgs: 1, isFunction: true),
                                          Operator(representation: "acos", priority: 0, associativity: Associativity.Left, imp: Functions._acos, numArgs: 1, isFunction: true),

                                          Operator(representation: "min", priority: 0, associativity: Associativity.Left, imp: Functions._min, numArgs: 2, isFunction: true),
                                          Operator(representation: "max", priority: 0, associativity: Associativity.Left, imp: Functions._max, numArgs: 2, isFunction: true)]

    private var formula: String = ""
    private var arguments: [String] = []
    private var operatorStack: [String] = []
    private var outputStack: [String] = []
    private var ready: Bool = false
    private var containsX: Bool = false

    public init(expression: String) {
        reset(expression: expression)
    }

    /**
     Resets the parser with the given expression string.
     
     - parameter expression: The string to parse.
    */
    public func reset(expression: String) {

        formula = expression.replacingOccurrences(of: " ", with: "").lowercased()
        arguments = []
        operatorStack = []
        outputStack = []
        ready = false
        containsX = false

    }

    /**
     Processes the input string with error checing

     - Throws: An NSError containing an error code and the parse failure reason,
    */
    public func prepare() throws {

        prepareArguments()

        do {
            try parseArguments()
        } catch let error as NSError {
            throw error
        } catch {
        }

        ready = true

        return

    }

    /**
     Gets all of the input operators' string representations

     - Parameter operators: The operators to get the string representations from
     - Returns: An array of string containing the string representations
    */
    private func getOperatorsStrings(operators: [Operator]) -> [String] {

        var returnValue: [String] = []

        for op in operators {
            returnValue.append(op.representation)
        }

        return returnValue

    }

    /**
     Gets an operator from it's string representation

     - Parameter representation: The operators representations
     - Returns: An operator or nil if does not exist
    */
    private func getOperator(representation: String) -> Operator? {

        for op in operators {
            if op.representation == representation {
                return op
            }
        }

        return nil

    }

    /**
     Splits the input string into an array of string containing each argument
    */
    private func prepareArguments() {

        var lastCut = 0

        let opStrings = getOperatorsStrings(operators: operators)

        for i in 0 ..< formula.count {

            let currentChar = String(formula.at(index: i))

            if opStrings.contains(currentChar) {

                let cut = formula.keeping(range: lastCut ... i)

                if cut != "" {
                    arguments.append(cut)
                }

                arguments.append(String(formula.at(index: i)))
                lastCut = i

            }

        }

        if lastCut < formula.count {

            let cut = formula.keeping(range: lastCut ... formula.count)
            if cut != "" {
                arguments.append(cut)
            }

        }

    }

    /**
     Converts the argument string array into a Reverse Polish Notation array
     https://en.wikipedia.org/wiki/Shunting-yard_algorithm

     - Throws: An NSError containing an error code and the parse failure reason,
    */
    private func parseArguments() throws {

        let opStrings = getOperatorsStrings(operators: operators)

        for argument in arguments {

            let number: Float? = Float(argument)

            if number != nil {

                if number == 0 { throw NSError(domain: "", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "You may not use 0 in your equations."])}

                outputStack.append(argument)
                continue
            }

            if argument == "pi" {
                outputStack.append(argument)
                continue
            }

            if argument == "x" {
                containsX = true
                outputStack.append(argument)
                continue
            }

            if argument == "," { continue; }

            if argument == "(" {

                operatorStack.append(argument)
                continue

            }

            if(argument == ")") {

                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Bad Parentheses"])

                if operatorStack.count == 0 { throw error }

                while operatorStack.last! != "(" {
                    outputStack.append(operatorStack.popLast()!)
                    if operatorStack.count <= 0 { throw error }
                }

                if operatorStack.last! == "(" {
                    _ = operatorStack.popLast()
                }

                if operatorStack.count == 0 { throw error }

                if getOperator(representation: operatorStack.last!)!.isFunction {
                    outputStack.append(operatorStack.popLast()!)
                }

                continue

            }

            if opStrings.contains(argument) {

                let currentOperator = getOperator(representation: argument)!

                if currentOperator.isFunction {
                    operatorStack.append(argument)
                    continue
                }

                while (operatorStack.last != nil) &&
                        ((getOperator(representation: operatorStack.last!)!.priority < currentOperator.priority) ||
                            (getOperator(representation: operatorStack.last!)!.priority == currentOperator.priority) &&
                            currentOperator.associativity == Associativity.Left) && (operatorStack.last! != "(") {

                    outputStack.append(operatorStack.popLast()!)

                }

                operatorStack.append(argument)
                continue

            }

            throw NSError(domain: "", code: -2, userInfo: [NSLocalizedFailureReasonErrorKey: String(format: "Invalid Argument: %@", argument)])

        }

        for arg in operatorStack {

            if arg == "(" || arg == ")" { throw NSError(domain: "", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Bad Parentheses"]); }
            outputStack.append(operatorStack.popLast()!)

        }

        return

    }

    /**
     Calculates the expression

     - Throws: An NSError containing an error code and the parse failure reason,
     - Returns: The operation result
    */
    public func calculate() throws -> Float {

        if !ready { throw NSError(domain: "", code: -3, userInfo: [NSLocalizedFailureReasonErrorKey: "Parser is not ready. Make sure you call prepare() and that your formula is valid."]); }

        if containsX { throw NSError(domain: "", code: -4, userInfo: [NSLocalizedFailureReasonErrorKey: "Your formula contains \"x\" so a value can't be calculated. Use getExpression() instead."]); }

        while outputStack.count > 1 {

            var procArgs: [String] = []
            var optOp = getOperator(representation: outputStack[0])

            while optOp == nil {
                procArgs.append(outputStack.remove(at: 0))
                optOp = getOperator(representation: outputStack[0])
            }

            let op = getOperator(representation: outputStack.remove(at: 0))!

            var numbers: [Float] = []
            let idx = procArgs.count - op.numArgs

            for _ in 0 ..< op.numArgs {
                if procArgs[idx] == "pi" { numbers.append(Float.pi); procArgs.remove(at: idx); continue; }
                if Float(procArgs[idx]) != nil { numbers.append(Float(procArgs.remove(at: idx))!) }
            }

            procArgs.append(String(op.imp!(numbers)))
            procArgs.reverse()

            while procArgs.count > 0 {
                outputStack.insert(procArgs.remove(at: 0), at: 0)
            }

        }

        return Float(outputStack[0])!

    }

    /**
     Generates a block of code that calculates the expression (if containing x)

     - Throws: An NSError containing an error code and the parse failure reason
     - Returns: A block taking a float (x) as an argument and returning the expression's result
    */
    func generateExpression() throws -> ((Float) -> Float) {

        if !ready { throw NSError(domain: "", code: -3, userInfo: [NSLocalizedFailureReasonErrorKey: "Parser is not ready. Make sure you call prepare() and that your formula is valid."]); }

        if !containsX { throw NSError(domain: "", code: -3, userInfo: [NSLocalizedFailureReasonErrorKey: "Your formula does not contain \"x\" so an expression can't be generated from it."]); }

        var funcStack: [([Float]) -> Float] = []

        while outputStack.count > 1 {

            var procArgs: [String] = []
            var optOp = getOperator(representation: outputStack[0])

            while optOp == nil {
                procArgs.append(outputStack.remove(at: 0))
                optOp = getOperator(representation: outputStack[0])
            }

            let op = getOperator(representation: outputStack.remove(at: 0))!

            if procArgs.contains("x") || procArgs.contains("_") {

                var numbers: [Float] = []
                var xPos: [Int] = []
                var fPos: [Int] = []

                let idx = procArgs.count - op.numArgs

                for i in 0 ..< op.numArgs {
                    if procArgs[idx] == "x" { xPos.append(i); procArgs.remove(at: idx); continue; }
                    if procArgs[idx] == "_" { fPos.append(i); procArgs.remove(at: idx); continue; }
                    if procArgs[idx] == "pi" { numbers.append(Float.pi); procArgs.remove(at: idx); continue; }
                    if Float(procArgs[idx]) != nil { numbers.append(Float(procArgs.remove(at: idx))!)}
                }

                let block = { [constNums = numbers, constFuncs = funcStack, a = xPos, b = fPos] (x: [Float]) -> Float in

                    var copy = constNums

                    for i in (0 ..< a.count).reversed() {
                        copy.insert(x[0], at: copy.count < a[i] ? copy.endIndex : a[i])
                    }

                    for i in (0 ..< b.count).reversed() {
                        copy.insert(constFuncs[i](x), at: copy.count < b[i] ? copy.endIndex : b[i])
                    }

                    return op.imp!(copy)

                }

                procArgs.append("_")

                for _ in 0 ..< fPos.count {
                    _ = funcStack.remove(at: 0)
                }

                funcStack.insert(block, at: 0)

            } else {

                var numbers: [Float] = []
                let idx = procArgs.count - op.numArgs

                for _ in 0 ..< op.numArgs {
                    if procArgs[idx] == "pi" { numbers.append(Float.pi); procArgs.remove(at: idx); continue; }
                    if Float(procArgs[idx]) != nil { numbers.append(Float(procArgs.remove(at: idx))!) }
                }

                procArgs.append(String(op.imp!(numbers)))

            }

            procArgs.reverse()

            while procArgs.count > 0 {
                outputStack.insert(procArgs.remove(at: 0), at: 0)
            }

        }

        let finalFunc = funcStack.count > 0 ? { (x: Float) -> Float in

            return funcStack[0]([x])

        } : { (x: Float) -> Float in return x; }

        return finalFunc

    }

}
