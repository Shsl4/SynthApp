//
//  ParserFunctions.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation

extension Parser {

    public class Functions {

        @inlinable @inline(__always) public static func _min(args: [Float]) -> Float {

            return min(args[0], args[1])

        }

        @inlinable @inline(__always) public static func _max(args: [Float]) -> Float {

            return max(args[0], args[1])

        }

        @inlinable @inline(__always) public static func _cos(args: [Float]) -> Float {

            return cos(args[0])

        }

        @inlinable @inline(__always) public static func _sin(args: [Float]) -> Float {

            return sin(args[0])

        }

        @inlinable @inline(__always) public static func _tan(args: [Float]) -> Float {

            return tan(args[0])

        }

        @inlinable @inline(__always) public static func _cosh(args: [Float]) -> Float {

            return cosh(args[0])

        }

        @inlinable @inline(__always) public static func _sinh(args: [Float]) -> Float {

            return sinh(args[0])

        }

        @inlinable @inline(__always) public static func _tanh(args: [Float]) -> Float {

            return tanh(args[0])

        }

        @inlinable @inline(__always) public static func _acos(args: [Float]) -> Float {

            return acos(args[0])

        }

        @inlinable @inline(__always) public static func _asin(args: [Float]) -> Float {

            return asin(args[0])

        }

        @inlinable @inline(__always) public static func _atan(args: [Float]) -> Float {

            return atan(args[0])

        }

        @inlinable @inline(__always) public static func _acosh(args: [Float]) -> Float {

            return acosh(args[0])

        }

        @inlinable @inline(__always) public static func _asinh(args: [Float]) -> Float {

            return asinh(args[0])

        }

        @inlinable @inline(__always) public static func _atanh(args: [Float]) -> Float {

            return atanh(args[0])

        }

        @inlinable @inline(__always) public static func _pow( args: [Float]) -> Float {

            return pow(args[0], args[1])

        }

        @inlinable @inline(__always) public static func _add( args: [Float]) -> Float {

            return args[0] + args[1]

        }

        @inlinable @inline(__always) public static func _sub( args: [Float]) -> Float {

            return args[0] - args[1]

        }

        @inlinable @inline(__always) public static func _mul( args: [Float]) -> Float {

            return args[0] * args[1]

        }

        @inlinable @inline(__always) public static func _div( args: [Float]) -> Float {

            return args[0] / args[1]

        }

        @inlinable @inline(__always) public static func _mod( args: [Float]) -> Float {

            return args[0].truncatingRemainder(dividingBy: args[1])

        }

    }

}
