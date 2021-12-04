//
//  Synthesizer.swift
//  SynthApp
//
//  Created by Pierre Juliot on 14/04/2021.
//

import Foundation
import AVFoundation
import CoreAudio
import AudioToolbox
import Accelerate

let audioEngine: AudioEngine = AudioEngine()
let midiInstance: MIDIManager = MIDIManager()
let parser: Parser = Parser(expression: "")
let twoPi: Float = 2.0 * Float.pi

/**
    Engine that creates the SynthAudioUnit and executes the signal generation loop
 */
public class AudioEngine {

    public let engine: AVAudioEngine
    public let factory: AudioUnitFactory
    private(set) public var initialized = false

    public init() {

        engine = AVAudioEngine()
        factory = AudioUnitFactory()

    }

    public func getAudioUnit() -> SynthAudioUnit {
        assert(initialized,
               "You must call start() before trying to get the AudioUnit. Wait for everything to finish initializing")
        return factory.audioUnit!
    }

    public func start() throws {

        let mainMixer = engine.mainMixerNode
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)
        let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                        sampleRate: outputFormat.sampleRate,
                                        channels: 2,
                                        interleaved: outputFormat.isInterleaved)

        let description = AudioComponentDescription(componentType: kAudioUnitType_Generator,
                                                    componentSubType: kAudioUnitSubType_MIDISynth,
                                                    componentManufacturer: kAudioUnitManufacturer_Apple,
                                                    componentFlags: 0, componentFlagsMask: 0)

        do {

            _ = try factory.createAudioUnit(with: description)

            engine.attach(factory.avAudioUnit!)
            engine.connect(factory.avAudioUnit!, to: mainMixer, format: inputFormat)
            engine.connect(mainMixer, to: output, format: outputFormat)
            mainMixer.outputVolume = 0.5

            engine.prepare()
            initialized = true

            _ = try engine.start()

        } catch {
            throw NSError(domain: "", code: -3,
                          userInfo: [NSLocalizedFailureReasonErrorKey: "Failed to initialize audio engine."])
        }

    }

}
