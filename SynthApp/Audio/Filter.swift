//
//  Filter.swift
//  SynthApp
//
//  Created by Pierre Juliot on 17/04/2021.
//

import Foundation

/*
    In order to implement these filters, I watched the video below explaining how it works
    https://www.youtube.com/watch?v=XVOdqJy-Rfg (Amazing video! 👍)
 */

/**
 Filters an audio signal
 */
public protocol Filter {

    init(sampleRate: Float, frequency: Float, q: Float)
    func process(sample: Float) -> Float
    func bypassed() -> Bool

    func getSampleRate() -> Float
    func getCutoffFrequency() -> Float
    func getQ() -> Float

    func setCutoffFrequency(_ frequency: Float)
    func setQ(_ q: Float)
    func setBypassed(_ bypassed: Bool)

}

public class EmptyFilter: Filter {

    let sampleRate: Float

    public func setCutoffFrequency(_ frequency: Float) { return; }
    public func setQ(_ q: Float) { return; }

    public func getCutoffFrequency() -> Float { return 0.0; }
    public func getQ() -> Float { return 0.0; }

    public func bypassed() -> Bool { return false; }
    public func setBypassed(_ bypassed: Bool) {}

    public required init(sampleRate: Float, frequency: Float, q: Float) {
        self.sampleRate = sampleRate
    }

    public func process(sample: Float) -> Float { return sample; }

    public func getSampleRate() -> Float { return 0.0; }

}

class SimpleHighPassFilter: Filter {

    private let sampleRate: Float

    private var lastInput: Float = 0.0

    public func setCutoffFrequency(_ frequency: Float) { return; }
    public func setQ(_ q: Float) { return; }

    public func getCutoffFrequency() -> Float { return 0.0; }
    public func getQ() -> Float { return 0.0; }

    public func bypassed() -> Bool { return false; }
    public func setBypassed(_ bypassed: Bool) {}

    required init(sampleRate: Float, frequency: Float, q: Float) {
        self.sampleRate = sampleRate
    }

    func process(sample: Float) -> Float {

        let returnValue = sample - lastInput
        lastInput = sample
        return returnValue

    }

    func getSampleRate() -> Float {
        return self.sampleRate
    }

}

class SimpleLowPassFilter: Filter {

    private let sampleRate: Float
    private var lastOutput: Float = 0.0
    private let alpha: Float = 0.99

    public func setCutoffFrequency(_ frequency: Float) { return; }
    public func setQ(_ q: Float) { return; }

    public func getCutoffFrequency() -> Float { return 0.0; }
    public func getQ() -> Float { return 0.0; }

    public func bypassed() -> Bool { return false; }
    public func setBypassed(_ bypassed: Bool) {}

    required init(sampleRate: Float, frequency: Float, q: Float) {
        self.sampleRate = sampleRate
    }

    func process(sample: Float) -> Float {

        let returnValue = alpha * lastOutput + (1.0 - alpha) * sample
        lastOutput = returnValue
        return returnValue

    }

    func getSampleRate() -> Float {
        return self.sampleRate
    }

}

class CombFilter: Filter{
    
    let sampleRate: Float;
    var q: Float;
    var frequency: Float;
    var isBypassed: Bool;
    
    // The comb delay (in samples)
    var combDelay: Int;
    let scaleFactor: Float;
    var lastSamples: [Float];
    
    required init(sampleRate: Float, frequency: Float, q: Float) {
        self.sampleRate = sampleRate;
        self.frequency = frequency;
        self.q = q;
        self.isBypassed = false;
        self.combDelay = 10;
        self.scaleFactor = 1.0;
        self.lastSamples = Array(repeating: 0, count: self.combDelay);
    }
    
    func process(sample: Float) -> Float {
        
        if bypassed() { return sample; }
        
        lastSamples.append(sample);
        let newSample = sample + scaleFactor * lastSamples[0];
        lastSamples.remove(at: 0);
        
        return newSample;
        
    }
    
    func bypassed() -> Bool {
        return self.isBypassed;
    }
    
    func getSampleRate() -> Float {
        return self.sampleRate;
    }
    
    func getCutoffFrequency() -> Float {
        return Float(self.combDelay);
    }
    
    func getQ() -> Float {
        return self.q;
    }
    
    func setCutoffFrequency(_ frequency: Float) {
        self.combDelay = Int(frequency);
    }
    
    func setQ(_ q: Float) {
        self.q = q;
    }
    
    func setBypassed(_ bypassed: Bool) {
        self.isBypassed = bypassed;
    }
    
}

/**
    A second order low pass filter
 */
class LowPassFilter: Filter {

    private let sampleRate: Float
    private var cutoffFrequency: Float
    private var q: Float
    private var bypassFilter: Bool = false

    var gB0: Float = 0.0
    var gB1: Float = 0.0
    var gB2: Float = 0.0
    var gA1: Float = 0.0
    var gA2: Float = 0.0

    var lastIn1: Float = 0.0
    var lastIn2: Float = 0.0
    var lastOut1: Float = 0.0
    var lastOut2: Float = 0.0

    private func calculateCoefficients() {

        let k = tanf(Float.pi * cutoffFrequency / sampleRate)
        let norm = 1.0 / (1 + k / q + k * k)

        gB0 = k * k * norm
        gB1 = 2.0 * gB0
        gB2 = gB0
        gA1 = 2 * (k * k - 1) * norm
        gA2 = (1 - k / q + k * k) * norm

    }

    required init(sampleRate: Float, frequency: Float, q: Float) {
        self.sampleRate = sampleRate
        self.cutoffFrequency = frequency
        self.q = q
    }

    func process(sample: Float) -> Float {

        if bypassed() { return sample; }

        let out: Float = gB0 * sample
            + gB1 * lastIn1
            + gB2 * lastIn2
            - gA1 * lastOut1
            - gA2 * lastOut2

        lastIn2 = lastIn1
        lastIn1 = sample

        lastOut2 = lastOut1
        lastOut1 = out

        return out

    }

    func getSampleRate() -> Float {
        return self.sampleRate
    }

    public func setCutoffFrequency(_ frequency: Float) { self.cutoffFrequency = frequency; calculateCoefficients(); }
    public func setQ(_ q: Float) { self.q = q; calculateCoefficients(); }

    public func getCutoffFrequency() -> Float { return cutoffFrequency; }
    public func getQ() -> Float { return q; }

    public func bypassed() -> Bool { return bypassFilter; }
    public func setBypassed(_ bypassed: Bool) { bypassFilter = bypassed; }

}
