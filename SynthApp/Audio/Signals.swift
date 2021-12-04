//
//  Signals.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import CoreAudio

@inlinable @inline(__always) func linearTodB(_ value: Float) -> Float {
    return 20 * log10(value)
}

@inlinable @inline(__always) func dBToLinear(_ value: Float) -> Float {
    return pow(10.0, value / 20.0)
}

/**
    The default synthesizer signals
 */
public class Signals {

    @inlinable @inline(__always) public static func sawtoothDown(phase: Float) -> Float {
        return (2.0 * (phase * (1.0 / (2.0 * Float.pi)))) - 1.0
    }

    @inlinable @inline(__always) public static func sawtoothUp(phase: Float) -> Float {
        return 1.0 - 2.0 * (phase * (1.0 / (2.0 * Float.pi)))
    }

    @inlinable @inline(__always) public static func square(phase: Float) -> Float {
        if phase <= Float.pi {
            return 1.0
        } else {
            return -1.0
        }    }

    @inlinable @inline(__always) public static func whiteNoise(phase: Float) -> Float {
        return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
    }

    @inlinable @inline(__always) public static func triangle(phase: Float) -> Float {

        var value = (2.0 * (phase * (1.0 / (2.0 * Float.pi)))) - 1.0
        if value < 0.0 {
            value = -value
        }
        return 2.0 * (value - 0.5)

    }

    @inlinable @inline(__always) public static func flatLine(phase: Float) -> Float {
        return 0.0
    }

}
