//
//  Ramp.swift
//  SynthApp
//
//  Created by Pierre Juliot on 17/04/2021.
//

import Foundation

/**
  An object that ramps to a certain value at a given rate
*/
public class Ramp {

    private var sampleRate: Float
    private var currentValue: Float
    private var increment: Float
    private var targetValue: Float = 0.0
    private var counter: Int

    public init() {
        self.currentValue = 0
        self.increment = 0
        self.counter = 0
        self.sampleRate = 1
    }

    public init(sampleRate: Float) {
        self.currentValue = 0
        self.increment = 0
        self.counter = 0
        self.sampleRate = sampleRate
    }

    public func setSampleRate(_ rate: Float) {
        sampleRate = rate
    }

    public func setValue(_ value: Float) {
        targetValue = value
        currentValue = value
        increment = 0
        counter = 0
    }

    public func rampTo(value: Float, time: Float) {
        if time <= 0.0 {
            setValue(value)
            return
        }
        targetValue = value
        increment = (value - currentValue) / (sampleRate * time)
        counter = Int(sampleRate * time)
    }

    public func process() -> Float {
        if counter > 0 {
            counter -= 1
            currentValue += increment
        } else {
            currentValue = targetValue
        }

        return currentValue
    }

    public func finished() -> Bool {
        return (counter == 0)
    }

}
