//
//  Voice.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import CoreAudio
import AudioUnit

/**
    Object that calculates a signal.
 */
public class Voice {

    public let voiceID: Int
    public let envelope: Envelope

    private(set) public var signalFunction: (Float) -> Float = sin
    private(set) public var isPlaying: Bool = false
    private(set) public var lastPlayedNote: Int = -1

    private let oscEnvelopeCallback: (Int) -> Void

    private var currentPhase: Float = 0
    private var phaseIncrement: Float = 0
    private var amplitude: Float = 1.0
    private var sampleRate: Float
    private var currentVelocity: Float = 0
    private var frequency: Float = 0.0

    public init(sampleRate: Float, voiceID: Int, envelopeReleased: @escaping (Int) -> Void) {
        self.sampleRate = sampleRate
        self.voiceID = voiceID
        self.oscEnvelopeCallback = envelopeReleased
        self.envelope = Envelope(sampleRate: sampleRate)
        self.envelope.setReleasedCallback(onEnvelopeReleased)
    }

    public func setSignalFunction(_ signal: @escaping (Float) -> Float) {
        signalFunction = signal
    }

    public func setTuning(_ tuning: Float) {

        currentPhase = Float(arc4random_uniform(UInt32(Float.pi * 100.0))) / 100.0
        phaseIncrement = (twoPi / sampleRate) * (frequency + tuning)

    }

    func start(noteNumber: Int, velocity: Int, tuning: Float) {

        currentVelocity = Float(velocity) / 127.0
        currentPhase = Float(arc4random_uniform(UInt32(Float.pi * 100.0))) / 100.0
        frequency = MIDIManager.getMIDINoteFrequencyInHertz(noteNumber: noteNumber)
        phaseIncrement = (twoPi / sampleRate) * (frequency + tuning)
        lastPlayedNote = noteNumber
        isPlaying = true
        envelope.trigger()

    }

    public func stop() {
        envelope.release()
    }

    public func kill() {
        envelope.stop()
    }

    private func onEnvelopeReleased() {

        isPlaying = false
        phaseIncrement = 0.0
        currentVelocity = 0
        oscEnvelopeCallback(voiceID)

    }

    private func updatePhase() {

        currentPhase += phaseIncrement

        if currentPhase >= twoPi {
            currentPhase -= twoPi
        }
        if currentPhase < 0.0 {
            currentPhase += twoPi
        }

    }

    public func process() -> Float {

        if !isPlaying { return 0.0; }

        let returnValue = signalFunction(currentPhase) * envelope.process() * currentVelocity
        updatePhase()
        return returnValue

    }

}
